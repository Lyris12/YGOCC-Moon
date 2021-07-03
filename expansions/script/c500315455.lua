function c500315455.initial_effect(c)
	  aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,7,c500315455.filter1,2)
	c:EnableReviveLimit() 
--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500315455,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,0x11e0)
	 e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCondition(c500315455.eqcon)
	e1:SetCost(c500315455.eqcost)
	e1:SetTarget(c500315455.eqtg)
	e1:SetOperation(c500315455.eqop)
	c:RegisterEffect(e1)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
			--evolute summon
  --  local e4=Effect.CreateEffect(c)
  --  e4:SetDescription(aux.Stringid(500315455,0))
 --   e4:SetCategory(CATEGORY_DESTROY)
 --   e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  --  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
   -- e4:SetCondition(c500315455.descon)
   -- e4:SetTarget(c500315455.destg)
   -- e4:SetOperation(c500315455.desop)
	--c:RegisterEffect(e4)
end
function c500315455.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_PLANT) 
end

function c500315455.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function c500315455.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function c500315455.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(500315455)==0
end
function c500315455.xfilter(c)
	return  c:IsAbleToChangeControler()
end
function c500315455.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE)   end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c500315455.xfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c500315455.xfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c500315455.eqlimit(e,c)
	return e:GetOwner()==c
end
function c500315455.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local atk=tc:GetTextAttack()
			local def=tc:GetTextDefense()
			if tc:IsFacedown() or atk<0 then atk=0 end
			if tc:IsFacedown() or def<0 then def=0 end
			if not Duel.Equip(tp,tc,c,false) then return end
			--Add Equip limit
			tc:RegisterFlagEffect(500315455,RESET_EVENT+0x1fe0000,0,0)
			e:SetLabelObject(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			e1:SetValue(c500315455.eqlimit)
			tc:RegisterEffect(e1)
			if atk>0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+0x1fe0000)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
			if def>0 then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_EQUIP)
				e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				e3:SetReset(RESET_EVENT+0x1fe0000)
				e3:SetValue(def)
				tc:RegisterEffect(e3)
			end
	end
end
end
function c500315455.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+388 and c:GetMaterial():IsExists(c500315455.pmfilter,1,nil)
end
function c500315455.pmfilter(c)
	return c:IsCode(160002123)
end
function c500315455.deesfilter(c)
return c:IsFaceup() and c:IsDestructable()
end
function c500315455.destg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
local g=Duel.GetMatchingGroup(c500315455.deesfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c500315455.desop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(c500315455.deesfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
if g:GetCount()>0 then
Duel.Destroy(g,REASON_EFFECT)
end
end