--All-Rose Dragon of Rose VINE
function c16000550.initial_effect(c)
			aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,8,c16000550.filter2,2,2,function(ec,tp,g) return g:FilterCount(c16000550.filter1,nil)==1 end)
	c:EnableReviveLimit() 
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(16000550,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c16000550.eqcon)
	e1:SetCost(c16000550.eqcost)
	e1:SetTarget(c16000550.eqtg)
	e1:SetOperation(c16000550.eqop)
	c:RegisterEffect(e1)
   --equip
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetDescription(aux.Stringid(16000550,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c16000550.atkcon)
	e2:SetCost(c16000550.atkcost)
	e2:SetTarget(c16000550.atktg)
	e2:SetOperation(c16000550.atkop)
	c:RegisterEffect(e2)
 
end
function c16000550.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c16000550.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
   e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function c16000550.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c16000550.filter,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_EXTRA)
end
function c16000550.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16000550.filter),tp,LOCATION_EXTRA,LOCATION_EXTRA,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if not Duel.Equip(tp,tc,c,true) then return end
	local atk=tc:GetTextAttack()/2
			local def=tc:GetTextDefense()/2
			if tc:IsFacedown() or atk<0 then atk=0 end
			if tc:IsFacedown() or def<0 then def=0 end
			if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(16000550,RESET_EVENT+0x1fe0000,0,0)
	e:SetLabelObject(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c16000550.eqlimit)
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

function c16000550.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
function c16000550.checku(sg,ec,tp)
return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function c16000550.filter1(c,ec,tp)
	return c:IsType(TYPE_NORMAL)
end
function c16000550.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) 
end
function c16000550.adcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c16000550.eqfilter,nil)
	return g:GetCount()>0
end
function c16000550.eqcon(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(16000550)==0 and e:GetHandler():IsLinkState()
end
function c16000550.eqfilter(c)
	return c:GetFlagEffect(16000550)~=0
end
function c16000550.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c16000550.eqfilter,nil)
	return g:GetCount()==0
end
function c16000550.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkState()
end
function c16000550.xxxfilter(c)
	return c:GetLevel()>0 and c:IsType(TYPE_NORMAL)  and c:IsAbleToRemove()
end
function c16000550.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	  local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,3,REASON_COST)
end
function c16000550.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c16000550.xxxfilter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c16000550.xxxfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	 Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c16000550.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) and  Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0  then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*100)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

