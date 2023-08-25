--Solar System Simurgh
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,1,1,aux.NOT(Card.IsNeutral),1)
	--Once per turn, if a card(s) you control would be destroyed by an opponent's card effect, you can discard 1 card instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned, or if another monster(s) is Special Summoned, except by the effect of "Solar System Simurgh": You can apply 1 of these effects (but you cannot apply that same effect of "Solar System Simurgh" again this turn).
	--● Special Summon 1 monster from your GY, except "Solar System Simurgh".
	--● Draw 1 card.
	--● Gain 1500 LP.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39185163,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.dfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,tp)
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0))
end
function s.repval(e,c)
	return s.dfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
function s.cfilter(c,re)
	return not re:GetHandler():IsCode(id) or c:IsCode(id)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,re)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and not c:IsCode(id)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	local opt=aux.Option(tp,id,1,b1,b2,b3)
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g1:GetCount()>0 then
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif opt==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.Recover(tp,1500,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
	end
end