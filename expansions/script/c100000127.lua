--MMS - Samurai
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_MMS),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	aux.AddContactFusionProcedureGlitchy(c,0,false,SUMMON_TYPE_FUSION,s.cfmaterial,LOCATION_ONFIELD,0,nil,aux.ContactFusionMaterialsToDeck)
	c:EnableReviveLimit()
	--All "MMS -" Fusion Monsters you control gain 400 ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(s.target)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--[[If a Level 6 or higher "MMS -" Fusion Monster(s) you control is destroyed and sent to the GY, while this card is banished or in your GY, even during the Damage Step:
	You can Special Summon this card, but return it to the Extra Deck when it leaves the field.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	RMChk:SetLabelObject(GYChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GB)
	e2:SetLabelObject(GYChk)
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
function s.cfmaterial(c)
	return (c:IsFusionSetCard(ARCHE_MMS) or c:IsRace(RACE_WARRIOR)) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

--E1
function s.target(e,c)
	return c:IsMonster(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS)
end

--E2
function s.filter(c,tp,se)
	local re=c:GetReasonEffect()
	if not (se==nil or not re or re~=se) then return false end
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousTypeOnField(TYPE_FUSION) and c:IsPreviousSetCard(ARCHE_MMS) and c:GetPreviousLevelOnField()>=6
		and c:IsMonster(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS) and c:IsLevelAbove(6)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,e:GetLabelObject():GetLabelObject())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP,nil,LOCATION_DECKSHF)
	end
end