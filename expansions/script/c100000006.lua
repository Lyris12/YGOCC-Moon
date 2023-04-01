--Extreme Esprision
--Script by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--If you control a Psychic monster: Target 1 card in your opponent's GY; banish it.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(s.rmvcond)
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
	--If this card is added to your hand, except by drawing it: You can target 1 face-up monster your opponent controls; attach it to an "Esprision" Xyz monster you control as material. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_HAND)
	e2:HOPT()
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_PSYCHIC),tp,LOCATION_MZONE,0,1,nil)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.atchfilter(c,tp)
	return c:IsMonster() and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,c,c)
end
function s.xyzfilter(c,mc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xe50) and mc:IsCanOverlay(c:GetControler())
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&LOCATION_DECK==LOCATION_DECK and c:GetPreviousControler()==tp and not c:IsReason(REASON_DRAW)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.atchfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.atchfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atchfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,tc,tc) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,tc,tc)
		if #xg>0 then
			Duel.HintSelection(xg)
			local xc=xg:GetFirst()
			if not tc:IsImmuneToEffect(e) then
				Duel.Attach(tc,xc)
			end
		end
	end
end