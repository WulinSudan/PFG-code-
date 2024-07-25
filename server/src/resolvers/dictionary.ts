import Dictionary from "../model/dictionary";

export const dictionaryResolvers = {
  Query: {
    // Define tus resolvers de Query aquí, si tienes alguno
  },

  Mutation: {
    addDictionary: async (_root: any, { input: { encrypt_message, account, operation } }: any) => {

      try {
        // Verificar que encrypt_message no es null o vacío
        if (!encrypt_message) {
          throw new Error("Encrypt message cannot be null or empty");
        }

        // Obtener la fecha y hora actuales
        const now = new Date(); 

        const dictionaryInput = {
          encrypt_message,
          account,
          operation,
          create_date: now, // Usar la fecha actual
        };

        const dictionary = new Dictionary(dictionaryInput);
        await dictionary.save();
        
        console.log("generat un codi qr");
        return dictionary;
      } catch (error: any) {
        console.error("Error details:", error);
        if (error.code === 11000) {
          throw new Error("Encrypt message already exists");
        }
        throw new Error("An unexpected error occurred: " + error.message);
      }
    },
  },
};
