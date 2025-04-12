# Project Management Implementation Specification

## Overview
A comprehensive system for managing job assessments and active projects, with different workflows for initial site visits and ongoing work. The system provides mobile-friendly interfaces for workers to access daily assignments and record necessary information.

## Data Model Extension

### Project Model
```javascript
// backend/src/models/Project.js
{
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  client_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'clients',
      key: 'id'
    },
    field: 'client_id'
  },
  estimate_id: {
    type: DataTypes.UUID,
    allowNull: true, // Optional, as some projects start as assessments
    references: {
      model: 'estimates',
      key: 'id'
    },
    field: 'estimate_id'
  },
  type: {
    type: DataTypes.ENUM('assessment', 'active'),
    allowNull: false,
    defaultValue: 'assessment',
    field: 'type'
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed'),
    defaultValue: 'pending',
    allowNull: false,
    field: 'status'
  },
  scheduled_date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
    field: 'scheduled_date'
  },
  scope: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'scope'
  },
  created_at: {
    type: DataTypes.DATE,
    field: 'created_at'
  },
  updated_at: {
    type: DataTypes.DATE,
    field: 'updated_at'
  }
}
```

### ProjectInspection Model
```javascript
// backend/src/models/ProjectInspection.js
{
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  project_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'projects',
      key: 'id'
    },
    field: 'project_id'
  },
  type: {
    type: DataTypes.ENUM('checklist', 'note'),
    allowNull: false,
    field: 'type'
  },
  category: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'category'
  },
  content: {
    type: DataTypes.JSONB, // For structured checklist items or free-form notes
    allowNull: false,
    field: 'content'
  },
  created_at: {
    type: DataTypes.DATE,
    field: 'created_at'
  }
}
```

### ProjectPhoto Model
```javascript
// backend/src/models/ProjectPhoto.js
{
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  project_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'projects',
      key: 'id'
    },
    field: 'project_id'
  },
  inspection_id: {
    type: DataTypes.UUID,
    allowNull: true, // Optional link to specific inspection item
    references: {
      model: 'project_inspections',
      key: 'id'
    },
    field: 'inspection_id'
  },
  photo_type: {
    type: DataTypes.ENUM('before', 'after', 'receipt', 'assessment'),
    allowNull: false,
    field: 'photo_type'
  },
  file_path: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'file_path'
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'notes'
  },
  created_at: {
    type: DataTypes.DATE,
    field: 'created_at'
  }
}
```

## Frontend Implementation

### Views

#### Projects Dashboard (Mobile-First)
```vue
<!-- frontend/src/views/projects/ProjectsDashboard.vue -->
<template>
  <div class="projects-dashboard">
    <!-- Today's Projects Section -->
    <section class="today-projects">
      <h2 class="text-xl font-semibold mb-4">Today's Jobs</h2>
      <div class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in todayProjects"
          :key="project.id"
          :project="project"
          class="card"
        />
      </div>
    </section>

    <!-- Upcoming Projects -->
    <section class="upcoming-projects mt-8">
      <h2 class="text-xl font-semibold mb-4">Upcoming</h2>
      <div class="grid grid-cols-1 gap-4">
        <ProjectCard
          v-for="project in upcomingProjects"
          :key="project.id"
          :project="project"
          class="card"
        />
      </div>
    </section>
  </div>
</template>
```

#### Project Card Component
```vue
<!-- frontend/src/components/projects/ProjectCard.vue -->
<template>
  <div 
    :class="[
      'project-card p-4 rounded-lg shadow',
      statusColorClass
    ]"
    @click="navigateToProject"
  >
    <div class="flex justify-between items-start">
      <div>
        <h3 class="font-semibold">{{ project.client.name }}</h3>
        <p class="text-sm">{{ project.client.address }}</p>
      </div>
      <BaseBadge
        :variant="statusVariant"
        size="sm"
      >
        {{ project.status }}
      </BaseBadge>
    </div>
    
    <div class="mt-2 text-sm">
      <p>{{ project.scope }}</p>
    </div>

    <!-- Assessment Requirements or Progress Info -->
    <div class="mt-4 flex justify-between items-center">
      <div v-if="project.type === 'assessment'">
        <BaseIcon name="clipboard-check" />
        <span>Assessment Required</span>
      </div>
      <div v-else>
        <BaseIcon name="check-circle" />
        <span>Work in Progress</span>
      </div>
    </div>
  </div>
</template>

<script setup>
const statusColorClass = computed(() => {
  switch (props.project.type) {
    case 'assessment': return 'bg-red-50 dark:bg-red-900/10';
    case 'active': 
      return props.project.status === 'completed' 
        ? 'bg-green-50 dark:bg-green-900/10'
        : 'bg-yellow-50 dark:bg-yellow-900/10';
    default: return '';
  }
});
</script>
```

#### Project Detail View
```vue
<!-- frontend/src/views/projects/ProjectDetail.vue -->
<template>
  <div class="project-detail pb-safe-area">
    <!-- Header with client info and status -->
    <header class="sticky top-0 bg-white dark:bg-gray-800 z-10 p-4 shadow">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-xl font-semibold">{{ project.client.name }}</h1>
          <p class="text-sm">{{ project.client.address }}</p>
        </div>
        <BaseBadge
          :variant="statusVariant"
          size="lg"
        >
          {{ project.status }}
        </BaseBadge>
      </div>
    </header>

    <!-- Project Info -->
    <div class="p-4">
      <section class="mb-6">
        <h2 class="text-lg font-semibold mb-2">Scope</h2>
        <p>{{ project.scope }}</p>
      </section>

      <!-- Assessment Form or Work Progress -->
      <AssessmentForm 
        v-if="project.type === 'assessment'"
        :project="project"
        @update="refreshProject"
      />
      <WorkProgress
        v-else
        :project="project"
        @update="refreshProject"
      />

      <!-- Photos Section -->
      <PhotosSection
        :project="project"
        :photo-type="project.type === 'assessment' ? 'assessment' : 'work'"
      />
    </div>

    <!-- Bottom Action Bar -->
    <div class="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-800 p-4 shadow-up">
      <div v-if="project.type === 'assessment'">
        <BaseButton
          variant="primary"
          block
          @click="createEstimate"
        >
          Create Estimate
        </BaseButton>
      </div>
      <div v-else class="flex space-x-4">
        <BaseButton
          variant="secondary"
          flex="1"
          @click="markComplete"
        >
          Mark Complete
        </BaseButton>
        <BaseButton
          variant="primary"
          flex="1"
          @click="viewEstimate"
        >
          View Estimate
        </BaseButton>
      </div>
    </div>
  </div>
</template>
```

### Assessment Form Component
```vue
<!-- frontend/src/components/projects/AssessmentForm.vue -->
<template>
  <div class="assessment-form">
    <!-- Structured Checklist -->
    <section class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Assessment Checklist</h3>
      <div class="space-y-4">
        <div 
          v-for="item in checklistItems"
          :key="item.id"
          class="p-4 bg-gray-50 dark:bg-gray-900/50 rounded"
        >
          <BaseCheckbox
            v-model="item.completed"
            :label="item.label"
          />
          <BaseTextarea
            v-if="item.completed"
            v-model="item.notes"
            placeholder="Add notes..."
            class="mt-2"
          />
          <!-- Photo Upload Option -->
          <PhotoUpload
            v-if="item.completed"
            :project-id="props.project.id"
            :inspection-id="item.id"
            photo-type="assessment"
            class="mt-2"
          />
        </div>
      </div>
    </section>

    <!-- Free-form Notes -->
    <section class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Additional Notes</h3>
      <BaseTextarea
        v-model="additionalNotes"
        placeholder="Add any additional observations..."
        rows="4"
      />
    </section>
  </div>
</template>
```

### Work Progress Component
```vue
<!-- frontend/src/components/projects/WorkProgress.vue -->
<template>
  <div class="work-progress">
    <!-- Progress Checklist -->
    <section class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Work Progress</h3>
      <div class="space-y-4">
        <div 
          v-for="item in workItems"
          :key="item.id"
          class="p-4 bg-gray-50 dark:bg-gray-900/50 rounded"
        >
          <BaseCheckbox
            v-model="item.completed"
            :label="item.label"
          />
          <div v-if="item.completed" class="mt-2 space-y-2">
            <PhotoUpload
              :project-id="props.project.id"
              :inspection-id="item.id"
              photo-type="after"
              label="Add completion photos"
            />
            <BaseTextarea
              v-model="item.notes"
              placeholder="Add completion notes..."
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Receipt Upload -->
    <section class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Receipts</h3>
      <PhotoUpload
        :project-id="props.project.id"
        photo-type="receipt"
        label="Upload receipts"
      />
    </section>
  </div>
</template>
```

## Backend Implementation

### Service Layer Updates

```javascript
// backend/src/services/projectService.js

class ProjectService {
  // Get projects for today
  async getTodayProjects() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    return await Project.findAll({
      where: {
        scheduled_date: today
      },
      include: [{
        model: Client,
        attributes: ['name', 'address']
      }],
      order: [
        ['type', 'DESC'],  // assessments first
        ['created_at', 'ASC']
      ]
    });
  }

  // Create assessment project
  async createAssessment(data) {
    return await Project.create({
      ...data,
      type: 'assessment',
      status: 'pending'
    });
  }

  // Convert assessment to estimate
  async convertToEstimate(projectId) {
    const project = await Project.findByPk(projectId, {
      include: [
        {
          model: ProjectInspection,
          where: { type: 'checklist' }
        }
      ]
    });

    // Create estimate from assessment data
    const estimate = await estimateService.createEstimate({
      client_id: project.client_id,
      // Map assessment data to estimate items
    });

    // Update project with estimate
    await project.update({
      estimate_id: estimate.id,
      type: 'active',
      status: 'in_progress'
    });

    return { project, estimate };
  }
}
```

## Mobile Optimizations

1. Responsive Layout Adjustments:
```css
/* Safe area handling for mobile */
.pb-safe-area {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Sticky header for mobile */
.sticky-header {
  position: sticky;
  top: env(safe-area-inset-top);
  z-index: 10;
}
```

2. Touch-Friendly Controls:
```css
/* Larger touch targets */
.touch-target {
  min-height: 44px;
  min-width: 44px;
}

/* Swipe actions */
.swipe-actions {
  touch-action: pan-y;
}
```

3. Photo Upload Optimizations:
```javascript
// Compress photos before upload
async function compressPhoto(file) {
  const options = {
    maxSizeMB: 1,
    maxWidthOrHeight: 1920,
    useWebWorker: true
  };
  
  try {
    return await imageCompression(file, options);
  } catch (error) {
    console.error('Error compressing image:', error);
    return file;
  }
}
```

## Success Criteria

1. Workers can easily view their assigned jobs for the day
2. Assessment workflow captures all necessary information
3. Photo uploads work reliably on mobile devices
4. Easy conversion from assessment to estimate
5. Clear status tracking throughout the project lifecycle
6. Efficient organization of photos by type
7. Smooth mobile experience with offline support