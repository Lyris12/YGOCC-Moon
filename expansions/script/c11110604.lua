--Bismus, Demimetalurgos Marionette
--Bismus, Demimetalurgo Marionetta
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,1,1,aux.NOT(Card.IsNeutral),1)
	--[[During the Main Phase (Quick Effect): You can increase or reduce your Engaged Drive Monster's Energy by its Level.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(aux.MainPhaseCond())
	e1:SetTarget(s.entg)
	e1:SetOperation(s.enop)
	c:RegisterEffect(e1)
	--[[ If a "Metalurgos" Drive Monster(s) becomes Engaged while this card is in your GY (except during the Damage Step):
	You can banish 1 Drive Monster from your GY; Special Summon this card, but banish it when it leaves the field.]]
	local se=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_ENGAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(se)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.BanishCost(aux.MonsterFilter(TYPE_DRIVE),LOCATION_GRAVE,0,1,1,true))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
end
--E1
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=Duel.GetEngagedCard(tp)
		return ec and ec:IsMonster(TYPE_DRIVE) and ec:HasLevel() and ec:IsCanIncreaseOrDecreaseEnergy(ec:GetLevel(),tp,REASON_EFFECT)
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetEngagedCard(tp)
	if ec and ec:IsMonster(TYPE_DRIVE) and ec:HasLevel() and ec:IsCanIncreaseOrDecreaseEnergy(ec:GetLevel(),tp,REASON_EFFECT) then
		ec:IncreaseOrDecreaseEnergy(ec:GetLevel(),tp,REASON_EFFECT,true,e:GetHandler(),e)
	end
end

--E2
function s.cfilter(c,tp,se)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_METALURGOS) and (se==nil or c:GetReasonEffect()~=se)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,se)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
end