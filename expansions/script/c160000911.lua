--Carole, Empress of Fiber VINE
function c160000911.initial_effect(c)
		 aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,8,c160000911.filter1,2)
	c:EnableReviveLimit()

 --battle indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
   local e2=e1:Clone()
   e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)

  --Special Summon
   -- local e4=Effect.CreateEffect(c)
 --   e3:SetDescription(aux.Stringid(160000911,1))
 --   e3:SetType(EFFECT_TYPE_IGNITION)
 --   e3:SetCategory(CATEGORY_TOHAND)
  --  e3:SetCode(EVENT_FREE_CHAIN)
  --  e3:SetRange(LOCATION_GRAVE)
   -- e3:SetCountLimit(1,160000911)
   -- e3:SetCost(c160000911.thcost)
   -- e3:SetTarget(c160000911.thtg)
   -- e3:SetOperation(c160000911.thop)
   -- c:RegisterEffect(e3)

		local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160000911,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
   e3:SetRange(LOCATION_MZONE)
	 e3:SetProperty(EFFECT_FLAG_DELAY)
   -- e1:SetHintTiming(0,0x1c0)
	e3:SetCountLimit(1)
	e3:SetCost(c160000911.cost)
	e3:SetTarget(c160000911.target)
	e3:SetOperation(c160000911.operation)
	c:RegisterEffect(e3)
  --  local e2=e1:Clone()
  --  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  --  c:RegisterEffect(e2)
  --  local e3=e1:Clone()
  --  e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
  --  e3:SetTarget(c160000911.target2)
  --  c:RegisterEffect(e3)

	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(160000911,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,160000911+EFFECT_COUNT_CODE_DUEL)
	e4:SetCost(c160000911.spcost)
	e4:SetTarget(c160000911.sptg)
	e4:SetOperation(c160000911.spop)
	c:RegisterEffect(e4)



end
function c160000911.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) or c:IsRace(RACE_PLANT)  
end

function c160000911.cfilter(c)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function c160000911.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
 local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)  end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
	c:RegisterFlagEffect(160000911,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c160000911.filter(c)
	return c:IsSetCard(0x185a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c160000911.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c160000911.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c160000911.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c160000911.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c160000911.thop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSetCard(0x85a) and tc:IsType(TYPE_MONSTER) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c160000911.xxfilter(c,tp,ep,val)
	return c:IsFaceup() and c:GetSummonPlayer()~=tp and not c:IsDisabled()
end

function c160000911.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,5,REASON_COST)  end
	e:GetHandler():RemoveEC(tp,5,REASON_COST)
	c:RegisterFlagEffect(160000911,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c160000911.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return eg:IsExists(c160000911.xxfilter,1,nil,tp) end
	local g=eg:Filter(c160000911.xxfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetChainLimit(c160000911.limit(Duel.GetCurrentChain()))
end
function c160000911.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	  local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(tc)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_BASE_ATTACK)
		e3:SetValue(tc:GetBaseAttack()/2)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
		end
end
function c160000911.limit(ch)
	return function(e,lp,tp)
		return not Duel.GetChainInfo(ch,CHAININFO_TARGET_CARDS):IsContains(e:GetHandler())
	end
end
function c160000911.cfilter(c)
	return c:IsSetCard(0x185a) and c:IsAbleToRemoveAsCost()
end

function c160000911.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c160000911.cfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c160000911.cfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c160000911.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c160000911.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
	end
end