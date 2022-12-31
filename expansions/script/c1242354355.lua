
--Flamiller Fangking

function c1242354355.initial_effect(c)
  
	 c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	 e1:SetType(EFFECT_TYPE_FIELD)
	 e1:SetRange(LOCATION_MZONE)
	 e1:SetTargetRange(0,LOCATION_MZONE)
	 e1:SetTarget(c1242354355.tg)
	 e1:SetCode(EFFECT_DISABLE)
	 c:RegisterEffect(e1)
	 
	 local e2=Effect.CreateEffect(c)
	 e2:SetCategory(CATEGORY_DECKDES)
	 e2:SetType(EFFECT_TYPE_QUICK_F)
	 e2:SetCode(EVENT_CHAINING)
	 e2:SetRange(LOCATION_MZONE)
	 e2:SetCondition(c1242354355.condition)
	 e2:SetTarget(c1242354355.target)
	 e2:SetOperation(c1242354355.operation)
	 c:RegisterEffect(e2)
end 
--Mill
function c1242354355.condition(e,tp,eg,ep,ev,re,r,rp)
	
	return rp==1-tp and re:GetHandler():GetCode()~=1242354355
  end
function c1242354355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1242354355.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,1,tp,LOCATION_DECK)
end
function c1242354355.operation(e,tp,eg,ep,ev,re,r,rp)
	 Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
 end  


--Negate eff
function c1242354355.tg(e,c)
local tp=e:GetHandlerPlayer()
local egy=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)*100


return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and c:GetAttack()<=egy
   
 end