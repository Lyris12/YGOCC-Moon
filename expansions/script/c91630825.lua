--Lich-Lord Naz'greth
local cid,id=GetID()
function cid.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,cid.mfilter,4,false)
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--If this card is Fusion Summoned: you can Special Summon 1 Level 5 or lower Zombie monster from either GY and 1 "Lich-Lord" monster from your GY. You can only use this effect of "Lich-Lord Naz'greth" once per turn.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	--Once per turn: You can discard up to 3 "Lich-Lord" monsters; draw the same number of cards.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetCondition(function(e,tp) return not Duel.IsPlayerAffectedByEffect(tp,91630825) end)
	e4:SetCost(function(e) e:SetLabel(100) return true end)
	e4:SetTarget(cid.drtg)
	e4:SetOperation(cid.drop)
	c:RegisterEffect(e4)
	local qe=e4:Clone()
	qe:SetType(EFFECT_TYPE_QUICK_O)
	qe:SetCode(EVENT_FREE_CHAIN)
	qe:SetCondition(function(e,tp) return Duel.IsPlayerAffectedByEffect(tp,91630825) end)
	c:RegisterEffect(qe)
	--change effect type
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.ccon)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
end
function cid.mfilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_ZOMBIE) and (not sg or sg:IsExists(Card.IsFusionSetCard,1,nil,0x2e7))
end
function cid.spfilter1(c,e,tp)
	return c:IsLevelBelow(5) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(cid.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function cid.spfilter2(c,e,tp)
	return c:IsSetCard(0x2e7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(cid.spfilter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or not Duel.IsExistingMatchingCard(cid.spfilter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(g+Duel.SelectMatchingCard(tp,cid.spfilter2,tp,LOCATION_GRAVE,0,1,1,g,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function cid.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2e7) and c:IsDiscardable()
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ch=e:GetLabel()==100
	local g=Duel.GetMatchingGroup(cid.costfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then e:SetLabel(0) return ch and #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local ct=Duel.SendtoGrave(g:SelectSubGroup(tp,function(g) return Duel.IsPlayerCanDraw(tp,#g) end,false,1,3),REASON_COST+REASON_DISCARD)
	Duel.SetTargetParam(ct)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cid.cfilter(c)
	return c:IsCode(91630827)
end
function cid.ccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil)
end
