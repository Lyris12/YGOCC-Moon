--ZA - Onomatopian Armorsmith
--Automate ID

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_ZW)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.equiptofilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_ZW) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
		and Duel.IsExistingTarget(s.equipwithfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.equipwithfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_UTOPIA)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local exc=e:IsCostChecked() and e:GetHandler() or nil
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.equiptofilter,tp,LOCATION_GRAVE,0,1,nil,exc,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.equiptofilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local eqc=g1:GetFirst()
	e:SetLabelObject(eqc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,s.equipwithfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g1,CATEGORY_EQUIP)
	if eqc:IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,eqc,1,tp,0)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local eqc=e:GetLabelObject()
	local g=Duel.GetTargetCards()
	if #g~=2 then return end
	local toequip,equipwith = g:GetFirst(),g:GetNext()
	if eqc~=toequip then
		toequip,equipwith = equipwith,toequip
	end
	if not Duel.Equip(tp,toequip,equipwith) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(equipwith)
	toequip:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
