--Seatector Lieutenant
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	aux.EnableUnionAttribute(c,cod.eqlimit)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cod.eqtg)
	e1:SetOperation(cod.eqop)
	c:RegisterEffect(e1)
	--Unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(cod.sptg)
	e2:SetOperation(cod.spop)
	c:RegisterEffect(e2)
	--Level Up
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_UPDATE_LEVEL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Equip 2
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(cod.spcon)
	e6:SetCost(cod.spcost)
	e6:SetTarget(cod.sptg2)
	e6:SetOperation(cod.spop2)
	c:RegisterEffect(e6)
end

--Equip
function cod.filter(c)
	local ct1,ct2=c:GetUnionCount()
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and ct2==0
end
function cod.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cod.filter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cod.filter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,cod.filter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cod.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not cod.filter(tc) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then return end
	aux.SetUnionState(c)
end

--Special Summon
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
--Replace Value
function cod.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0
end

--Equip Limit
function cod.eqlimit(e,c)
	return (c:IsAttribute(ATTRIBUTE_WATER) or e:GetHandler():GetEquipTarget()==c)
end

--Special Summon 2
function cod.spcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
end
function cod.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function cod.spfilter(c,e,tp)
	return c:IsSetCard(0x33F) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cod.ecfilter2(c,tp,tc)
	return c:IsSetCard(0x33F) and c:IsType(TYPE_MONSTER) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cod.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local eg=Duel.GetMatchingGroup(cod.ecfilter2,tp,LOCATION_HAND,0,nil,tp,tc)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(83013180,3)) then
			local sg=Duel.SelectMatchingCard(tp,cod.ecfilter2,tp,LOCATION_HAND,0,1,1,nil,tp,tc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local ec=sg:GetFirst()
			if ec and Duel.Equip(tp,ec,tc) then
				aux.SetUnionState(ec)
			end
		end
	end
end