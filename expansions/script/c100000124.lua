--MMS - Photon Messenger
--MMS - Messaggero Fotonico
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--If an "MMS -" or "Photon" monster(s) is Normal or Special Summoned (except during the Damage Step): You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--If this card is Special Summoned by its own effect: You can draw 1 card and reveal it, then, if it is a "MMS -", "Photon", or "Galaxy" monster, you can Special Summon it.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.ProcSummonedCond)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
--E1
function s.hspfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MMS,ARCHE_PHOTON)
end
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.hspfilter,1,e:GetHandler())
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local dr=Duel.GetOperatedGroup():GetFirst()
	if not aux.PLChk(dr,tp,LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,dr)
	if dr:IsMonster() and dr:IsSetCard(ARCHE_MMS,ARCHE_PHOTON,ARCHE_GALAXY) and Duel.GetMZoneCount(tp)>0 and dr:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.Ask(tp,id,2) then
		Duel.BreakEffect()
		if Duel.SpecialSummon(dr,0,tp,tp,false,false,POS_FACEUP)==0 then
			Duel.ShuffleHand(tp)
		end
	else
		Duel.ShuffleHand(tp)
	end
end