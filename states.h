

/*
#define SAVE_CONTEXT0()              \
    asm volatile (                   \
        "push r0              \n\t"  \
        "in   r0, __SREG__    \n\t"  \
        "push r0              \n\t"  \
        "push r1              \n\t"  \
        "clr  r1              \n\t"  \
        "push r2              \n\t"  \
        "push r3              \n\t"  \
        "push r4              \n\t"  \
        "push r5              \n\t"  \
        "push r6              \n\t"  \
        "push r7              \n\t"  \
        "push r8              \n\t"  \
        "push r9              \n\t"  \
        "push r10             \n\t"  \
        "push r11             \n\t"  \
        "push r12             \n\t"  \
        "push r13             \n\t"  \
        "push r14             \n\t"  \
        "push r15             \n\t"  \
        "push r16             \n\t"  \
        "push r17             \n\t"  \
        "push r18             \n\t"  \
        "push r19             \n\t"  \
        "push r20             \n\t"  \
        "push r21             \n\t"  \
        "push r22             \n\t"  \
        "push r23             \n\t"  \
        "push r24             \n\t"  \
        "push r25             \n\t"  \
        "push r26             \n\t"  \
        "push r27             \n\t"  \
        "push r28             \n\t"  \
        "push r29             \n\t"  \
        "push r30             \n\t"  \
        "push r31             \n\t"  \
    )
	
#define RESTORE_CONTEXT0()           \
    asm volatile (                   \
        "pop  r31             \n\t"  \
        "pop  r30             \n\t"  \
        "pop  r29             \n\t"  \
        "pop  r28             \n\t"  \
        "pop  r27             \n\t"  \
        "pop  r26             \n\t"  \
        "pop  r25             \n\t"  \
        "pop  r24             \n\t"  \
        "pop  r23             \n\t"  \
        "pop  r22             \n\t"  \
        "pop  r21             \n\t"  \
        "pop  r20             \n\t"  \
        "pop  r19             \n\t"  \
        "pop  r18             \n\t"  \
        "pop  r17             \n\t"  \
        "pop  r16             \n\t"  \
        "pop  r15             \n\t"  \
        "pop  r14             \n\t"  \
        "pop  r13             \n\t"  \
        "pop  r12             \n\t"  \
        "pop  r11             \n\t"  \
        "pop  r10             \n\t"  \
        "pop  r9              \n\t"  \
        "pop  r8              \n\t"  \
        "pop  r7              \n\t"  \
        "pop  r6              \n\t"  \
        "pop  r5              \n\t"  \
        "pop  r4              \n\t"  \
        "pop  r3              \n\t"  \
        "pop  r2              \n\t"  \
        "pop  r1              \n\t"  \
        "pop  r0              \n\t"  \
        "out __SREG__, r0     \n\t"  \
        "pop  r0              \n\t"  \
    )
	
#define SAVE_CONTEXT1()                    \
    asm volatile (                         \
        "push r0               \n\t"       \
        "in   r0, __SREG__     \n\t"       \
        "cli                   \n\t"       \
        "push r0               \n\t"       \
        "push r1               \n\t"       \
        "clr  r1               \n\t"       \
        "push r2               \n\t"       \
        "push r3               \n\t"       \
        "push r4               \n\t"       \
        "push r5               \n\t"       \
        "push r6               \n\t"       \
        "push r7               \n\t"       \
        "push r8               \n\t"       \
        "push r9               \n\t"       \
        "push r10              \n\t"       \
        "push r11              \n\t"       \
        "push r12              \n\t"       \
        "push r13              \n\t"       \
        "push r14              \n\t"       \
        "push r15              \n\t"       \
        "push r16              \n\t"       \
        "push r17              \n\t"       \
        "push r18              \n\t"       \
        "push r19              \n\t"       \
        "push r20              \n\t"       \
        "push r21              \n\t"       \
        "push r22              \n\t"       \
        "push r23              \n\t"       \
        "push r24              \n\t"       \
        "push r25              \n\t"       \
        "push r26              \n\t"       \
        "push r27              \n\t"       \
        "push r28              \n\t"       \
        "push r29              \n\t"       \
        "push r30              \n\t"       \
        "push r31              \n\t"       \
        "in   r26, __SP_L__    \n\t"       \
        "in   r27, __SP_H__    \n\t"       \
        "sts  currentTask + 0, r26 \n\t"   \
        "sts  currentTask + 1, r27 \n\t"   \
    )



#define RESTORE_CONTEXT1()                     \
    asm volatile (                             \
        "lds  r26, nextTask + 0    \n\t"       \
        "lds  r27, nextTask + 1    \n\t"       \
        "out  __SP_L__, r26        \n\t"       \
        "out  __SP_H__, r27        \n\t"       \
        "pop  r31                  \n\t"       \
        "pop  r30                  \n\t"       \
        "pop  r29                  \n\t"       \
        "pop  r28                  \n\t"       \
        "pop  r27                  \n\t"       \
        "pop  r26                  \n\t"       \
        "pop  r25                  \n\t"       \
        "pop  r24                  \n\t"       \
        "pop  r23                  \n\t"       \
        "pop  r22                  \n\t"       \
        "pop  r21                  \n\t"       \
        "pop  r20                  \n\t"       \
        "pop  r19                  \n\t"       \
        "pop  r18                  \n\t"       \
        "pop  r17                  \n\t"       \
        "pop  r16                  \n\t"       \
        "pop  r15                  \n\t"       \
        "pop  r14                  \n\t"       \
        "pop  r13                  \n\t"       \
        "pop  r12                  \n\t"       \
        "pop  r11                  \n\t"       \
        "pop  r10                  \n\t"       \
        "pop  r9                   \n\t"       \
        "pop  r8                   \n\t"       \
        "pop  r7                   \n\t"       \
        "pop  r6                   \n\t"       \
        "pop  r5                   \n\t"       \
        "pop  r4                   \n\t"       \
        "pop  r3                   \n\t"       \
        "pop  r2                   \n\t"       \
        "pop  r1                   \n\t"       \
        "pop  r0                   \n\t"       \
        "out  __SREG__, r0         \n\t"       \
        "pop  r0                   \n\t"       \
    )



#define SAVE_CONTEXT()                     \
    asm volatile (                         \
        "push r0               \n\t"       \
        "in   r0, __SREG__     \n\t"       \
        "cli                   \n\t"       \
        "push r0               \n\t"       \
        "push r1               \n\t"       \
        "clr  r1               \n\t"       \
        "push r2               \n\t"       \
        "push r3               \n\t"       \
        "push r4               \n\t"       \
        "push r5               \n\t"       \
        "push r6               \n\t"       \
        "push r7               \n\t"       \
        "push r8               \n\t"       \
        "push r9               \n\t"       \
        "push r10              \n\t"       \
        "push r11              \n\t"       \
        "push r12              \n\t"       \
        "push r13              \n\t"       \
        "push r14              \n\t"       \
        "push r15              \n\t"       \
        "push r16              \n\t"       \
        "push r17              \n\t"       \
        "push r18              \n\t"       \
        "push r19              \n\t"       \
        "push r20              \n\t"       \
        "push r21              \n\t"       \
        "push r22              \n\t"       \
        "push r23              \n\t"       \
        "push r24              \n\t"       \
        "push r25              \n\t"       \
        "push r26              \n\t"       \
        "push r27              \n\t"       \
        "push r28              \n\t"       \
        "push r29              \n\t"       \
        "push r30              \n\t"       \
        "push r31              \n\t"       \
        "in   r26, __SP_L__    \n\t"       \
        "in   r27, __SP_H__    \n\t"       \
        "sts  %0, r26          \n\t"       \
        "sts  %1, r27          \n\t"       \
        :                                  \
        : "m"(currentTask->stackPointer), "m"(*((uint8_t**)&currentTask->stackPointer) + 1) \
        : "r26", "r27"                     \
    )



#define RESTORE_CONTEXT()                       \
    asm volatile (                              \
        "lds  r26, %0          \n\t"            \
        "lds  r27, %1          \n\t"            \
        "out  __SP_L__, r26    \n\t"            \
        "out  __SP_H__, r27    \n\t"            \
        "pop  r31              \n\t"            \
        "pop  r30              \n\t"            \
        "pop  r29              \n\t"            \
        "pop  r28              \n\t"            \
        "pop  r27              \n\t"            \
        "pop  r26              \n\t"            \
        "pop  r25              \n\t"            \
        "pop  r24              \n\t"            \
        "pop  r23              \n\t"            \
        "pop  r22              \n\t"            \
        "pop  r21              \n\t"            \
        "pop  r20              \n\t"            \
        "pop  r19              \n\t"            \
        "pop  r18              \n\t"            \
        "pop  r17              \n\t"            \
        "pop  r16              \n\t"            \
        "pop  r15              \n\t"            \
        "pop  r14              \n\t"            \
        "pop  r13              \n\t"            \
        "pop  r12              \n\t"            \
        "pop  r11              \n\t"            \
        "pop  r10              \n\t"            \
        "pop  r9               \n\t"            \
        "pop  r8               \n\t"            \
        "pop  r7               \n\t"            \
        "pop  r6               \n\t"            \
        "pop  r5               \n\t"            \
        "pop  r4               \n\t"            \
        "pop  r3               \n\t"            \
        "pop  r2               \n\t"            \
        "pop  r1               \n\t"            \
        "pop  r0               \n\t"            \
        "out  __SREG__, r0     \n\t"            \
        "pop  r0               \n\t"            \
        :                                       \
        : "m"(nextTask->stackPointer), "m"(*((uint8_t**)&nextTask->stackPointer) + 1) \
        : "r26", "r27"                         \
    )
	
#define SAVE_CONTEXT_SIMP()         \
    asm volatile (                  \
        "in r26, __SP_L__     \n\t" \
        "in r27, __SP_H__     \n\t" \
        "sts current_sp, r26  \n\t" \
        "sts current_sp+1, r27\n\t" \
    );

#define RESTORE_CONTEXT_SIMP()       \
    asm volatile (                   \
        "lds r26, next_sp      \n\t" \
        "lds r27, next_sp+1    \n\t" \
        "out __SP_L__, r26     \n\t" \
        "out __SP_H__, r27     \n\t" \
    );

#define STACK_SIZE 64

// Task stacks
uint8_t task1_stack[STACK_SIZE];
uint8_t task2_stack[STACK_SIZE];

// Stack pointers
uint8_t *task1_sp;
uint8_t *task2_sp;

uint8_t *current_sp;
uint8_t *next_sp;

void init_stack(void (*task_func)(void), uint8_t *stack, uint8_t **sp_out) ;
void task_switch(void) ;
*/

