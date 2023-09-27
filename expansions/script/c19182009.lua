--Aircaster Luther
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHIC),2,63,true)
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	--spsummon restriction
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT(true)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--todeck
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsSpell(TYPE_EQUIP) and (not c:IsFacedown() or c:GetEquipTarget()~=nil)
end
function s.cfilter(c,fc)
	local eg=c:GetEquipGroup()
	return c:IsAbleToGraveAsCost() and eg and eg:IsExists(s.eqfilter,1,nil)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.atkval(e,c)
	return c:GetEquipCount()*500 
end

function s.filter(c,tp)
	return ((c:IsSetCard(ARCHE_AIRCASTER) and c:IsType(TYPE_MONSTER)) or c:IsSpell(TYPE_EQUIP)) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.filter2(c,eqc)
	return c:IsFaceup() and (not eqc:IsSpell(TYPE_EQUIP) or eqc:CheckEquipTarget(c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return true end
	local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_SZONE))
	local g=Duel.Select(HINTMSG_EQUIP,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,g,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<#g then return end
	for tc in aux.Next(g) do
		Duel.Hint(HINT_CARD,tp,tc:GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local eqg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil,tc)
		if #eqg>0 then
			Duel.HintSelection(eqg)
			local ec=eqg:GetFirst()
			if tc:IsSpell(TYPE_EQUIP) then
				Duel.Equip(tp,tc,ec,true,true)
			else
				Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,ec,true,true)
			end
		end
	end
	Duel.EquipComplete()
end

function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_AIRCASTER) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(sg,CATEGORY_TODECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end