--Howler Support Spirit
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--If a you control a Beast monster, and there are at least 2 Attributes among the monsters you control, you can Special Summon this card (from your hand).
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spsumcon)
	c:RegisterEffect(e1)
	--[[If a Beast monster(s) you control is destroyed, while this card is in your GY: You can Special Summon this card, 
	and if you do, it cannot be destroyed by battle or card effects this turn.]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(GYChk)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.attfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
function s.spsumcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and aux.GetAttributeCount(g)>=2
end

function s.cfilter(c,tp,se)
	return c:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and c:GetPreviousPosition()&POS_FACEUP>0 and c:GetPreviousControler()==tp and c:GetPreviousRaceOnField()&RACE_BEAST==RACE_BEAST
		and (se==nil or c:GetReasonEffect()~=se)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_BE_DESTROYED_BY_BATTLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(STRING_CANNOT_BE_DESTROYED_BY_EFFECT)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end