--Strix Support Spirit
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is sent to the GY: You can discard 1 Level 3 Beast monster, and if you do, draw 1 card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetTarget(s.drawtg)
	e1:SetOperation(s.drawop)
	c:RegisterEffect(e1)
	--[[If this card is banished while there are at least 2 different Attributes among the monsters you control:
	You can Special Summon this card, and if you do, treat it as a Tuner until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.dcfilter(c)
	return c:IsMonster() and c:IsLevel(3) and c:IsRace(RACE_BEAST) and c:IsDiscardable(REASON_EFFECT)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.dcfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	local pubg=g:Filter(Card.IsPublic,nil)
	if #pubg>0 and not g:IsExists(aux.NOT(Card.IsPublic),1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,pubg,1,tp,LOCATION_HAND)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_EFFECT|REASON_DISCARD)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.attfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE,0,nil)
	return aux.GetAttributeCount(g)>=2
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
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end