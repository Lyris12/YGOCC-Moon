--created & coded by Lyris
--鎧刻竜－サイバー・ダーク・ドラゴンストライク
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,s.mfilter,nil,nil,aux.NonTuner(nil),1,99)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_EQUIP)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsSynchroType(TYPE_TUNER) or c:IsSetCard(0x4093)
end
function s.filter(c)
	return c:IsLevelBelow(7) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		if not Duel.Equip(tp,tc,c,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(s.repval)
		tc:RegisterEffect(e3)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
function s.cfilter(c,e,tp)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
function s.eqfilter(c,lv)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(lv) and not c:IsForbidden()
end
function s.qfilter(c)
	return c:IsFacedown() and c:IsRace(RACE_MACHINE) and c:IsSetCard(0x4093)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetEquipGroup()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and g:IsExists(s.cfilter,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=g:FilterSelect(tp,s.cfilter,1,1,nil,e,tp):GetFirst()
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc:GetLevel()):GetFirst()
		if not ec then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local qc=Duel.SelectMatchingCard(tp,s.qfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if qc then
			Duel.BreakEffect()
			if not Duel.Equip(tp,ec,qc) then return end
			local e1=Effect.CreateEffect(qc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			ec:RegisterEffect(e1)
			local e2=Effect.CreateEffect(qc)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(math.max(atk,0))
			ec:RegisterEffect(e2)
			if qc:IsCode(18967507) then return end
			local e3=Effect.CreateEffect(qc)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(s.repval)
			ec:RegisterEffect(e3)
		end
	end
end
