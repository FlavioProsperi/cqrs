{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveGeneric #-}
module Data.CQRS.Internal.PersistedEvent
       ( PersistedEvent(..)
       , PersistedEvent'(..)
       , grow
       , shrink
       ) where

import Control.DeepSeq (NFData(..))
import Data.Bifunctor (Bifunctor(..))
import Data.Int (Int32)
import GHC.Generics (Generic)

-- | Persisted Event.
data PersistedEvent i e =
  PersistedEvent { peEvent :: !e              -- ^ Event.
                 , peSequenceNumber :: !Int32 -- ^ Sequence number within the aggregate.
                 }
  deriving (Show, Eq, Generic)

instance Bifunctor PersistedEvent where
  bimap _ g (PersistedEvent e seqNo) = PersistedEvent (g e) seqNo

instance (NFData e, NFData i) => NFData (PersistedEvent i e)

-- | Persisted Event with an associated aggregate ID.
data PersistedEvent' i e =
    PersistedEvent' { pepAggregateId :: !i
                    , pepEvent :: PersistedEvent i e
                    }
  deriving (Show, Eq, Generic)

instance Bifunctor PersistedEvent' where
    bimap f g (PersistedEvent' i pe) = PersistedEvent' (f i) (bimap f g pe)

instance (NFData e, NFData i) => NFData (PersistedEvent' i e)

-- | Augment a 'PersistedEvent' with an aggregate ID to form a 'PersistedEvent\''.
grow :: i -> PersistedEvent i e -> PersistedEvent' i e
grow i pe = PersistedEvent' i pe

-- | Shrink a 'PersistedEvent\'' to form a 'PersistedEvent'.
shrink :: PersistedEvent' i e -> PersistedEvent i e
shrink (PersistedEvent' _ pe) = pe