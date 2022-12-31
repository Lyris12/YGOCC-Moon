--Poisonous Dragon of Evil VINE
function c500316120.initial_effect(c)
	 aux.AddSynchroProcedure(c,aux.FilterBoolFunction(c500316120.synfilter),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	  local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c500316120.adcon)
	e1:SetValue(c500316120.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
	--cannot target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50031612,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c500316120.eqcon)
	e4:SetTarget(c500316120.eqtg)
	e4:SetOperation(c500316120.eqop)
	c:RegisterEffect(e4)
	
	 --atk/def
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetCondition(c500316120.adcon)
	e5:SetValue(c500316120.atkval)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	e6:SetCondition(c500316120.adcon)
	e6:SetValue(c500316120.defval)
	c:RegisterEffect(e6)
	
	   --Destroy
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(50031612,1))
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetHintTiming(0,0x11e0)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetTarget(c500316120.destg)
	e7:SetOperation(c500316120.desop)
	c:RegisterEffect(e7)


end



function c500316120.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
function c500316120.adcon(e)
	return e:GetHandler():GetEquipCount()>0
end
function c500316120.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end

function c500316120.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return c500316120.can_equip_monster(e:GetHandler())
end
function c500316120.eqfilter(c)
	return c:GetFlagEffect(500316120)~=0
end
function c500316120.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c500316120.eqfilter,nil)
	return g:GetCount()==0
end
function c500316120.eqfilter2(c,tp)
	return c:IsFaceup() and  (c:IsAbleToChangeControler() or c:IsControler(tp)) and not c:IsType(TYPE_SYNCHRO)
end
function c500316120.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c500316120.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c500316120.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c500316120.eqlimit(e,c)
	return e:GetOwner()==c
end
function c500316120.equip_monster(c,tp,tc)
	if not Duel.Equip(tp,tc,c,false) then return end
	--Add Equip limit
	tc:RegisterFlagEffect(500316120,RESET_EVENT+RESETS_STANDARD,0,0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c500316120.eqlimit)
	tc:RegisterEffect(e1)

end
function c500316120.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER)  then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c500316120.equip_monster(c,tp,tc)
		else Duel.SendtoGrave(tc,REASON_EFFECT) end
	end
end
function c500316120.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
function c500316120.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c500316120.eqfilter,nil)
	return g:GetCount()>0 and ep==tp
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
function c500316120.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end
function c500316120.adcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c500316120.eqfilter,nil)
	return g:GetCount()>0
end
function c500316120.atkval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c500316120.eqfilter,nil)
	local atk=g:GetFirst():GetTextAttack()/2
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or atk<0 then
		return 0
	else
		return atk
	end
end
function c500316120.defval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c500316120.eqfilter,nil)
	local def=g:GetFirst():GetTextDefense()/2
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or def<0 then
		return 0
	else
		return def
	end
end
function c500316120.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
function c500316120.desop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if g1:GetFirst():IsRelateToEffect(e) and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)
	end
end