/**
 * Student Numbers: XXXXXXXXX
 * Student Names  : Rethabile Siase
 * Question: Hardcoded Module Data
 */

// Structure: level -> semester -> list of {code, name}
const Map<String, Map<String, List<Map<String, String>>>> kModules = {
  '1st Year': {
    'Semester 1': [
      {'code': 'ITE115C', 'name': 'Information Technology Essentials I'},
      {'code': 'ITM115C', 'name': 'Information Technology Mathematics I'},
      {'code': 'LCS5011', 'name': 'Academic Literacy and Communication Studies'},
      {'code': 'PIM5011', 'name': 'Personal Information Management'},
      {'code': 'PSA115C', 'name': 'Problem Solving and Algorithms'},
      {'code': 'SOD115C', 'name': 'Software Development I'},
    ],
    'Semester 2': [
      {'code': 'INP125C', 'name': 'Internet Programming I'},
      {'code': 'ITE125C', 'name': 'Information Technology Essentials II'},
      {'code': 'ITM125C', 'name': 'Information Technology Mathematics II'},
      {'code': 'LCS5012', 'name': 'Academic Literacy and Communication Studies'},
      {'code': 'SOD125C', 'name': 'Software Development II'},
    ],
  },
  '2nd Year': {
    'Semester 1': [
      {'code': 'DBS216C', 'name': 'Databases II'},
      {'code': 'GID216C', 'name': 'Graphic Design II'},
      {'code': 'SOD216C', 'name': 'Software Development II A'},
      {'code': 'TPG216C', 'name': 'Technical Programming II A'},
      {'code': 'WEB215C', 'name': 'Web Content Management II'},
    ],
    'Semester 2': [
      {'code': 'GUD226C', 'name': 'Graphical User Interface Design II'},
      {'code': 'INT226C', 'name': 'Internet Technologies II'},
      {'code': 'SOD226C', 'name': 'Software Development II B'},
      {'code': 'SOE226C', 'name': 'Software Engineering II'},
      {'code': 'TPG226C', 'name': 'Technical Programming II B'},
    ],
  },
  '3rd Year': {
    'Semester 1': [
      {'code': 'CMN316C', 'name': 'Communication Networks III'},
      {'code': 'ITS316C', 'name': 'Information Technology and Society I'},
      {'code': 'SOD316C', 'name': 'Software Development III'},
      {'code': 'SOE316C', 'name': 'Software Engineering III'},
      {'code': 'TPG316C', 'name': 'Technical Programming III'},
    ],
    'Semester 2': [
      {'code': 'ITC327W', 'name': 'Work Integrated Learning in Information Technology'},
    ],
  },
};
