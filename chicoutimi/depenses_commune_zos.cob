       IDENTIFICATION DIVISION.                                        
       PROGRAM-ID. DEPENSES.                                           
                                                                       
                                                                       
       ENVIRONMENT DIVISION.                                           
       CONFIGURATION SECTION.                                          
       SOURCE-COMPUTER. MVS.                                           
       OBJECT-COMPUTER. MVS.                                           
                                                                       
       INPUT-OUTPUT SECTION.                                           
       FILE-CONTROL.                                                   
                SELECT BUYER-DATA ASSIGN TO DEPENS.                    
                SELECT TOTAL-DATA ASSIGN TO SORTIE.                              
                SELECT SORTED-DATA ASSIGN TO SYSWORK.              
      * SYSWORK = zone de travail "interne" a l OS/COBOL                
      * Mais n est pas toujours present sur PC                          
                                                                        
                                                                        
       DATA DIVISION.                                                   
       FILE SECTION.                                                    
       FD  BUYER-DATA                                                   
           RECORDING MODE IS F.                                         
       01  PEOPLE-RECORD.                                               
           05 NAME-IN   PICTURE X(20).                                  
           05 MONEY-SPENT-IN  PICTURE 9999V99.                          
           05   PICTURE X(1).                                                                                        				
           05 DATE-RECORD.                                             
              06 DAY-IN  PICTURE 99.                                   
              06 MONTH-IN  PICTURE 99.                                 
              06 YEAR-IN  PICTURE 9999.                                
                                                                       
       SD  SORTED-DATA.                                                
       01  SORTED-RECORD.                                              
           05 NAME-ST   PICTURE X(20).                                 
           05 MONEY-SPENT-ST  PICTURE 9(4)V99.                         
           05   PICTURE X(1).                                          
           05 DATE-ST.                                                 
              06 DAY-ST  PICTURE 99.                                   
              06 MONTH-ST  PICTURE 99.                                 
              06 YEAR-ST  PICTURE 9999.                                
                                                                       
       FD  TOTAL-DATA                                                  
           RECORDING MODE IS F.                                           
       01  PRINT-REC.                                                   
           05 NAME-OUT  PICTURE X(20).                                  
           05   PICTURE X(10).                                          
           05 TOTAL-OUT  PICTURE ZZZZ.99.                               
                                                                        
       WORKING-STORAGE SECTION.                                         
       01  ARE-THERE-MORE-RECORDS PICTURE XXX VALUE 'YES'.              
       77  CURRENT-NAME  PICTURE X(20).                                 
       77  CURRENT-SUM   PICTURE 9(4)V99.                               
       77  CURRENT-AVERAGE  PICTURE 9(4)V99.                            
       77  CURRENT-AV-ENTRIES  PICTURE 999.                             
       77  CURRENT-ENTRIES  PICTURE 999.                                
       01  IS-FIRST-ENTRY  PICTURE XXX VALUE 'YES'.                                           
           88 NOT-FIRST-ENTRY       VALUE 'NO '.                       
                                                                       
                                                                       
       PROCEDURE DIVISION.                                             
       100-MAIN-MODULE.                                                
           SORT SORTED-DATA ON ASCENDING KEY NAME-ST OF SORTED-RECORD  
                USING BUYER-DATA                                       
            OUTPUT PROCEDURE 200-AFTER-SORT                            
           STOP RUN.                                                   
                                                                       
       200-AFTER-SORT.                                                 
           MOVE 'YES' TO IS-FIRST-ENTRY                                
           OPEN OUTPUT TOTAL-DATA                                      
           PERFORM UNTIL ARE-THERE-MORE-RECORDS = 'NO'                 
      * Ceci est un commentaire... COL7 a * == commentaire             
      *      READ SORTED-DATA                                                               
      * On ne READ pas un SORT                                        
              RETURN SORTED-DATA                                      
            AT END                                                    
              MOVE 'NO ' TO ARE-THERE-MORE-RECORDS                    
              PERFORM 400-WRITE-SUM-TO-FILE                           
              PERFORM 500-TOTAL-AVERAGE-TO-FILE                       
            NOT AT END                                                
              PERFORM 300-COUNT-ROUTINE                               
                END-RETURN                                            
                END-PERFORM                                           
                CLOSE TOTAL-DATA.                                     
                                                                      
       300-COUNT-ROUTINE.                                             
      *     DISPLAY "Name temp : " NAME-ST                            
      *     DISPLAY "Money : " MONEY-SPENT-ST                         
           IF IS-FIRST-ENTRY = 'YES'                                  
      *         Premiere iteration, on initialize tout                	               
              MOVE NAME-ST TO CURRENT-NAME                             
              MOVE MONEY-SPENT-ST TO CURRENT-SUM                       
              MOVE 1 TO CURRENT-ENTRIES CURRENT-AV-ENTRIES             
              MOVE 0 TO CURRENT-AVERAGE                                
              MOVE 'NO ' TO IS-FIRST-ENTRY                             
           ELSE                                                        
              IF  NAME-ST = CURRENT-NAME                               
      *             2e iteration ou plus dans un meme bloc de nom      
      *      On ajoute la depense associee                             
                  ADD MONEY-SPENT-ST TO CURRENT-SUM                    
                  ADD 1 TO CURRENT-ENTRIES                             
              ELSE                                                     
      *             On change de nom, donc on calcule et on ecrit      
                  PERFORM 400-WRITE-SUM-TO-FILE                        
                  ADD CURRENT-SUM TO CURRENT-AVERAGE                   
                  ADD 1 TO CURRENT-AV-ENTRIES                                                  
      *      On reinitialize avec le nouveau nom                      
                  MOVE NAME-ST TO CURRENT-NAME                        
                  MOVE MONEY-SPENT-ST TO CURRENT-SUM                  
                  MOVE 1 TO CURRENT-ENTRIES                           
              END-IF                                                  
           END-IF.                                                    
                                                                      
       400-WRITE-SUM-TO-FILE.                                         
      *     move space permet de mettre les espaces ou il faut        
           MOVE SPACES TO PRINT-REC                                   
           MOVE CURRENT-NAME TO NAME-OUT                              
           MOVE CURRENT-SUM TO TOTAL-OUT                              
           WRITE PRINT-REC.                                           
                                                                      
       500-TOTAL-AVERAGE-TO-FILE.                                     
           ADD CURRENT-SUM TO CURRENT-AVERAGE                                             
           DIVIDE CURRENT-AV-ENTRIES INTO CURRENT-AVERAGE            
           MOVE "-------------------------------------" TO PRINT-REC 
           WRITE PRINT-REC                                           
           MOVE SPACES TO PRINT-REC                                  
           MOVE "TOTAL AVERAGE       " TO NAME-OUT                   
           MOVE CURRENT-AVERAGE TO TOTAL-OUT                         
           WRITE PRINT-REC.                                          
                                                                     
       END PROGRAM DEPENSES.                                         