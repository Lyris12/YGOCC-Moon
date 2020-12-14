--created by Moon Burst, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_EQUIP)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_EQUIP)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:GetEquipTarget():IsCode(id-15) and c:IsAbleToGrave()
end
function s.filter1(c,tp)
	return c:IsSetCard(0x191) and c:IsType(TYPE_UNION) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.filter2(c,eqc)
	return c:IsFaceup() and c:IsCode(id-15) and eqc:CheckEquipTarget(c) and aux.CheckUnionEquip(eqc,c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #eg==1 and s.filter(eg:GetFirst()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,1,1,nil,tp)
		local tc2,tc1=g:GetFirst()
		local qg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc2)
		if #qg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tg=qg:Select(tp,1,1,nil)
			Duel.HintSelection(tg)
			tc1=tg:GetFirst()
		else tc1=qg:GetFirst() end
		if tc2 and aux.CheckUnionEquip(tc1,tc2) and Duel.Equip(tp,tc1,tc2) then
			aux.SetUnionState(tc1)
		end
	end
end
