--Chronovert Chronobot
local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	--You cannot Special Summon monsters from the Extra Deck, except Time Leap Monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	c:RegisterEffect(e1)
	--You can Time Leap Summon 1 Time Leap Monster in addition to your Normal Time Leap Summon. (you can only gain this effect once per turn.)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_TIMELEAP_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
	--If a Time Leap Monster is Time Leap Summoned to a zone this card points to: You can make your opponent shuffle 1 card they control into the Deck (their choice).
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_TIMELEAP)
end
function s.cfilter(c,tp,lg)
	return c:IsType(TYPE_TIMELEAP) and lg:IsContains(c) and c:IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.tdfilter(c,tp)
	return Duel.IsPlayerCanSendtoDeck(tp,c)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.cfilter,1,nil,tp,lg) and Duel.IsExistingMatchingCard(s.tdfilter,1-tp,LOCATION_ONFIELD,0,1,nil,1-tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(1-tp,tdfilter,1-tp,LOCATION_ONFIELD,0,1,1,nil,1-tp)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE,1-tp)
	end
end