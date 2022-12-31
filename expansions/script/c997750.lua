--Scripted by IanxWaifu
--Divine-Eye's Awakening
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
--	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x12D9}
function s.counterfilter(c)
	return c:IsSetCard(0x12D9)
end
function s.filter(c,e)
	return c:IsAbleToGrave()
end
function s.rescon(sg)
    return sg:GetClassCount(Card.GetAttribute)==#sg
end
function s.xyzfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x12D9) and c:IsFaceup()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil)
    local dg=Group.CreateGroup(g):GetOverlayGroup()
--  if chk==0 then return g:GetClassCount(Card.GetAttribute)>=4 and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    if chk==0 then return dg:GetClassCount(Card.GetAttribute)>=2 end
    local tg=aux.SelectUnselectGroup(dg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
--  local e1=Effect.CreateEffect(e:GetHandler())
--	e1:SetType(EFFECT_TYPE_FIELD)
--	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
--	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
--	e1:SetReset(RESET_PHASE+PHASE_END)
--	e1:SetTargetRange(1,0)
--	e1:SetLabelObject(e)
--	e1:SetTarget(s.splimit)
--	Duel.RegisterEffect(e1,tp)
--	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x12D9)
end

--Test
function s.filter2(c,e,tp)
	return c:IsSetCard(0x12D9)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
