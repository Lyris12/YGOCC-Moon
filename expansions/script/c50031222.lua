--Fulla, Young Pixie of Rose VINE
  
function c50031222.initial_effect(c)
   aux.AddOrigEvoluteType(c)
 aux.AddEvoluteProc(c,nil,7,c50031222.filter2,2,2,function(ec,tp,g) return g:FilterCount(c50031222.filter1,nil)==1 end)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(50031222,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,50031222)
	e1:SetCondition(c50031222.condition)
	e1:SetCost(c50031222.cost)
	e1:SetTarget(c50031222.target)
	e1:SetOperation(c50031222.operation)
	c:RegisterEffect(e1)
   --equip
	 local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50031222,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,0x1e0)
	e3:SetCost(c50031222.eqcost)
	e3:SetTarget(c50031222.eqtg)
	e3:SetOperation(c50031222.eqop)
	c:RegisterEffect(e3)
 
end
function c50031222.condition(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388 and e:GetHandler():IsLinkState()
end
function c50031222.filter1(c,ec,tp)
	return c:IsType(TYPE_NORMAL)
end
function c50031222.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) 
end
function c50031222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)
and e:GetHandler():GetAttackAnnouncedCount()==0 end
		e:GetHandler():RemoveEC(tp,3,REASON_COST)
  local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function c50031222.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:GetControler()~=tp and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c50031222.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function c50031222.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x88,3,REASON_COST) 
 end
	c:RemoveCounter(tp,0x88,3,REASON_COST) 
  end
function c50031222.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50031222.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c50031222.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c50031222.filter(c)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c50031222.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()/2
		local def=tc:GetTextDefense()/2
	   if tc:IsFacedown() or atk<0 then atk=0 end
		if tc:IsFacedown() or def<0 then def=0 end
		if not Duel.Equip(tp,tc,c,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c50031222.eqlimit)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		e3:SetValue(c50031222.repval)
		tc:RegisterEffect(e3)
		 local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		e4:SetReset(RESET_EVENT+0x1fe0000)
		e4:SetValue(def)
		tc:RegisterEffect(e4)
	end
end
function c50031222.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
function c50031222.eqlimit(e,c)
	return e:GetOwner()==c
end