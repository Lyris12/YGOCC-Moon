--Yasmin Queen of Rose VINE

function c50031555.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,10,c50031555.mfilter1,3,function(ec,tp,g) return g:FilterCount(c50031555.mfilter2,nil)==1 end)
	c:EnableReviveLimit()
  --spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c50031555.splimit)
	c:RegisterEffect(e1)
	  --Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50031555,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c50031555.condition)
	e2:SetCost(c50031555.cost)
	e2:SetTarget(c50031555.target)
	e2:SetOperation(c50031555.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(50031555,1))
	e3:SetCondition(c50031555.condition2)
	c:RegisterEffect(e3)
   --immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(c50031555.immcon)
	e4:SetValue(c50031555.efilter)
	c:RegisterEffect(e4)
 --Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(50031555,2))
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c50031555.sumcon)
	e5:SetTarget(c50031555.sumtg)
	e5:SetOperation(c50031555.sumop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e7)
end
function c50031555.mfilter1(c) return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) end
function c50031555.mfilter2(c) return c:IsType(TYPE_NORMAL) end
function c50031555.splimit(e,se,sp,st)
	return st==SUMMON_TYPE_SPECIAL+388
end
function c50031555.immcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388 and e:GetHandler():IsLinkState()
end
--function c50031555.efilter(e,te)
  --  if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true end
   -- if te:IsActiveType(TYPE_MONSTER) and (te:IsHasType(0x7e0) or te:IsHasProperty(EFFECT_FLAG_FIELD_ONLY) or te:IsHasProperty(EFFECT_FLAG_OWNER_RELATE)) then
	 --   local evc=e:GetHandler():GetCounter(0x88)
	 --   local ec=te:GetOwner()
	 --   if ec:IsType(TYPE_XYZ) then
	 -- return ec:GetOriginalRank()<evc
	 --   else if ec:IsType(TYPE_LINK) then
	  --	  return ec:GetLink()<evc
	  --  else
		 --   return ec:GetOriginalLevel()<evc
	 --   end
   -- end
   -- return false
--end
--end
function c50031555.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c50031555.condition(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	return ex and tg~=nil 
end
function c50031555.condition2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg  and Duel.IsChainNegatable(ev)
end
function c50031555.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	   local c=e:GetHandler()
  if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	 e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function c50031555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c50031555.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c50031555.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c50031555.thfilter(c,e,tp)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_MONSTER) and  c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c50031555.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c50031555.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c50031555.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c50031555.sumop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)then
Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
