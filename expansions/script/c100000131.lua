--MMS - Musketeer d'Artagnan
--MMS - Moschettiere d'Artagnan
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,99)
	c:EnableReviveLimit()
	--If this card is Special Summoned: You can attach 1 "MMS -" monster that is banished or in your GY to this card as material.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--All "MMS -" Fusion Monsters you control gain 100 ATK/DEF for each of your banished cards.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(s.atktg)
	e2:SetValue(aux.ForEach(aux.TRUE,LOCATION_REMOVED,0,nil,100))
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--If this card destroys an opponent's monster by battle: You can draw 1 card.
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetFunctions(aux.bdocon,nil,aux.DrawTarget(),aux.DrawOperation())
	c:RegisterEffect(e3)
	--Once per turn (Quick Effect): You can detach 1 material from this card; Special Summon 1 "MMS -" monster that is banished or in your GY.
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:OPT()
	e4:SetRelevantTimings()
	e4:SetFunctions(nil,aux.DetachSelfCost(),s.sptg,s.spop)
	c:RegisterEffect(e4)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,6)
end
function s.xyzcheck(g)
	return g:IsExists(Card.IsSetCard,1,nil,ARCHE_MMS)
end

--E1
function s.atfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_MMS) and c:IsCanOverlay()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) or not c:IsRelateToChain() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.atfilter),tp,LOCATION_GB,LOCATION_REMOVED,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Attach(g,c)
	end
end

--E2
function s.atktg(e,c)
	return c:IsMonster(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS)
end

--E3
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_MMS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GB)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_GB,LOCATION_REMOVED,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
