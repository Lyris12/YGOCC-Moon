--Merroine of Fber VINE
function c160001313.initial_effect(c)
	   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,4,c160001313.filter1,1)
  --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c160001313.con)
	e1:SetOperation(c160001313.chainop)
	c:RegisterEffect(e1)
			 --tohand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(160001313,0))
	e0:SetCategory(CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_FREE_CHAIN)
   -- e0:SetHintTiming(0,0x1e0)
	e0:SetCountLimit(1)
	--e3:SetCondition(c160001313.condition)
	e0:SetCost(c160001313.cost)
	e0:SetTarget(c160001313.target)
	e0:SetOperation(c160001313.operation)
	c:RegisterEffect(e0)
end
function c160001313.con(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetEC()>0
end
function c160001313.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if  rc:IsSetCard(0x85a)  then
		Duel.SetChainLimit(c160001313.chainlm)
	end
end
function c160001313.chainlm(e,rp,tp)
	return tp==rp
end
function c160001313.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) or c:IsRace(RACE_PLANT) 
end

function c160001313.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
		 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
	--local e1=Effect.CreateEffect(c)
  --  e1:SetType(EFFECT_TYPE_FIELD)
   -- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
   -- e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  --  e1:SetReset(RESET_PHASE+PHASE_END)
  --  e1:SetLabelObject(c)
  --  e1:SetTargetRange(1,0)
  --  e1:SetTarget(c50031569.splimit)
   -- Duel.RegisterEffect(e1,tp)
end
function c160001313.filter(c)
	return c:IsType(TYPE_PENDULUM) and  c:IsFaceup() and c:IsAbleToDeck()
end
function c160001313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingMatchingCard(c160001313.filter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,0,0)
  
end
function c160001313.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c160001313.filter),tp,LOCATION_EXTRA,0,1,nil)
	if g:GetCount()<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
