--Mysterious Water Fairy
function c1600058.initial_effect(c)
	c:EnableReviveLimit()
	  --synchro summon
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,8,aux.TRUE,2)
	   --mat check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c1600058.valcheck)
	c:RegisterEffect(e0)
 --destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(1600058,0))
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1600058.condition)
	e1:SetCountLimit(1,1600058)
	e1:SetCost(c1600058.cost)
	e1:SetTarget(c1600058.target)
	e1:SetOperation(c1600058.operation)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
 --destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(1600058,1))
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1600058.condition2)
	e2:SetCountLimit(1,1600058)
	e2:SetCost(c1600058.cost2)
	e2:SetTarget(c1600058.target2)
	e2:SetOperation(c1600058.operation2)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)

 --destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetDescription(aux.Stringid(1600058,2))
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c1600058.condition3)
	e3:SetCountLimit(1,1600058)
	e3:SetCost(c1600058.cost3)
	e3:SetTarget(c1600058.target3)
	e3:SetOperation(c1600058.operation3)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)

   local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetDescription(aux.Stringid(1600058,3))
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c1600058.condition4)
	e4:SetCountLimit(1,1600058)
	e4:SetCost(c1600058.cost4)
	e4:SetTarget(c1600058.target4)
	e4:SetOperation(c1600058.operation4)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
		--atk
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c1600058.atkcon)
	e5:SetValue(500)
	e5:SetLabelObject(e0)
	c:RegisterEffect(e5)
	 local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	
  local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetDescription(aux.Stringid(1600058,4))
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c1600058.atkcon)
	e7:SetCountLimit(1,1600058)
	e7:SetCost(c1600058.cost5)
	e7:SetTarget(c1600058.target5)
	e7:SetOperation(c1600058.operation5)
	e7:SetLabelObject(e0)
	c:RegisterEffect(e7)
	
   --destroy
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(1600058,5))
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_BATTLE_START)
	e8:SetCondition(c1600058.tdcon)
	e8:SetTarget(c1600058.tdtg)
	e8:SetOperation(c1600058.tdop)
	e8:SetLabelObject(e0)
	c:RegisterEffect(e8)
end
function c1600058.valcheck(e,c)
	local g=c:GetMaterial()
	local typ=0
	local tc=g:GetFirst()
	while tc do
			typ=bit.bor(typ,tc:GetAttribute())
		tc=g:GetNext()
	end
	e:SetLabel(typ)
end
function c1600058.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_DARK)~=0
end
--function c1600058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 --   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
 --   e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
--end
function c1600058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,3,REASON_COST)
end
function c1600058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c1600058.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,aux.ExceptThisCard(e))
	Duel.Destroy(sg,REASON_EFFECT)
end
function c1600058.condition2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_LIGHT)~=0
end
--function c1600058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 --   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
 --   e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
--end
function c1600058.filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()  and c:IsDestructable()
end
function c1600058.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,2,REASON_COST)
end
function c1600058.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c1600058.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	local sg=Duel.GetMatchingGroup(c1600058.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c1600058.operation2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(c1600058.filter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	Duel.Destroy(sg,REASON_EFFECT)
end

function c1600058.condition3(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_FIRE)~=0
end
--function c1600058.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
 --   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
 --   e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
--end
function c1600058.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,2,REASON_COST)
end
function c1600058.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	  if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function c1600058.operation3(e,tp,eg,ep,ev,re,r,rp)
	   local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

function c1600058.condition4(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_WATER)~=0
end
--function c1600058.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
 --   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
 --   e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
--end
function c1600058.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,4,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,4,REASON_COST)
end
function c1600058.target4(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter1,tp,0,LOCATION_ONFIELD,1,nil) end
end
function c1600058.operation4(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(aux.disfilter1,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
function c1600058.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_EARTH)~=0
end

--function c1600058.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
 --   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
 --   e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
--end
function c1600058.spfilter(c,e,tp)
	return  c:IsSetCard(0xcf6) or (c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsType(TYPE_PANDEMONIUM)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c1600058.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,4,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,4,REASON_COST)
end
function c1600058.target5(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1600058.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
function c1600058.operation5(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0  then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1600058.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c1600058.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetLabelObject():GetLabel(),ATTRIBUTE_WIND)~=0
end
function c1600058.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsType(TYPE_EFFCT) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
end
function c1600058.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() then Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)end
end