--created by Alastar Rainford, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
	e1:SetCost(function(e) e:SetLabel(100) return true end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_FIRE)
		or Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c:GetOriginalAttribute()))
end
function s.filter(c,at)
	if at&0x11~=0 then
		if not c:IsAbleToRemove() then return false end
		return at==ATTRIBUTE_LIGHT or c:IsFacedown()
	elseif at==ATTRIBUTE_WIND then return c:IsAbleToHand()
	else return at==ATTRIBUTE_DARK and c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL+TYPE_TRAP) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=e:GetLabel()
	if chkc then return at~=ATTRIBUTE_FIRE and chkc:IsOnField() and s.filter(chkc,at) end
	if chk==0 then
		if at~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
	end
	local tc=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp):GetFirst()
	local att=tc:GetOriginalAttribute()
	local lv=tc:GetLevel()
	e:SetLabel(att)
	Duel.Release(tc,REASON_COST)
	if att==ATTRIBUTE_FIRE then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetLabelObject(tc)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*200)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,att)
		if att&0x11~=0 then
			e:SetCategory(CATEGORY_REMOVE)
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		elseif att&0x22~=0 then
			e:SetCategory(CATEGORY_DESTROY)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		else
			e:SetCategory(CATEGORY_TOHAND)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		end
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local at=e:GetLabel()
	if at==ATTRIBUTE_FIRE then Duel.Damage(1-tp,e:GetLabelObject():GetLevel()*200)
	else
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		if at&0x11~=0 then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif at&0x22~=0 then Duel.Destroy(tc,REASON_EFFECT)
		else Duel.SendtoHand(tc,nil,REASON_EFFECT) end
	end
end
