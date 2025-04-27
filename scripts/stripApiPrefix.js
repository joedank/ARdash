import { promises as fs } from 'fs';  
import fg from 'fast-glob';  
const files = await fg('frontend/src/services/**/*.js');  
for (const f of files) {  
  const t = await fs.readFile(f,'utf8');  
  const nt = t.replace(/(['"`])\/api\/([^'"]+)/g,'$1/$2');  
  if (t!==nt){await fs.writeFile(f,nt);console.log('fixed',f);}  
}