# Fichiers de test - Support format .csv/.dat

## Fichiers créés pour tester l'intégration

### 1. **test_data_csv_format.csv** et **test_data_csv_format_dat.dat**
- Format: time-course avec colonnes pour différentes mesures
- Naming: `Ctrl_High_Area1_E5` (VAR1_VAR2_VAR3 pattern)
- Structure: 
  - Première ligne: entête avec noms des mesures
  - Première colonne: timepoints (0, 5, 10, 15, 20, 25, 30)
  - Données: valeurs fluorescence simulées
  
**Utilité**: Tester le parsing de structure CSV/DAT avec plusieurs colonnes de mesure

### 2. **test_data_simple.csv** et **test_data_simple.dat**
- Format: simple avec lignes = variables (Fo, Fm, Fm_L, Fm_D)
- Naming: `PlantA_Ctrl_R1` (VAR1_VAR2_VAR3 pattern)
- Structure:
  - Première colonne: noms des variables
  - Autres colonnes: réplicats biologiques
  
**Utilité**: Tester le nécessite de labellisation interactive (Fo, Fm, Fm_L, Fm_D)

## Utilisation pour développement

### Phase 1 - Test lecture format
```R
source("helpers.R")
df1 <- read_fluorcam("sample_data/test_data_csv_format.csv")
df2 <- read_fluorcam("sample_data/test_data_simple.csv")
```

### Phase 2 - Test labellisation interactive
```R
# Fichiers simples nécessiteront interaction utilisateur:
# - Nombre de lignes Fm_L : 1
# - Nombre de lignes Fm_D : 1
df3 <- read_fluorcam("sample_data/test_data_simple.dat")
```

### Phase 3 - Test pipeline complet
```R
# Adapter process_data_files pour accepter fichiers CSV/DAT
var_names <- c("Plant", "Treatment", "Replicate")
df <- process_data_files(pattern = ".*\\.(csv|dat)$", var_names, dirpath = "sample_data")
```

## Notes

- Tous les fichiers utilisent le naming pattern: **VAR1_VAR2_VAR3**
- Les données fluorescence sont réalistes (basées sur chlorophylle)
- Les fichiers mix formats permettent de tester robustesse du code
