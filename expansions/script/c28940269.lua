--Marionightte Afterhours Show
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	aux.EnableChangeCode(c,Marionightte.ID,LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,ref.codecon)
	--No Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Trade
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(ref.sscon)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	c:RegisterEffect(e2)
	--Flicker
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(ref.destg)
	e3:SetOperation(ref.desop)
	c:RegisterEffect(e3)
end
function ref.codecon(e)
	return Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,TYPE_EXTRA)
end

--Trade
function ref.sscon(e,tp)
	return not (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE))
end
function ref.sscfilter(c,g)
	return (c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER) and c:IsAbleToGrave()
		and g:IsExists(Marionightte.IsRaceInText,1,nil,c:GetRace())
end
function ref.sscgfilter(g) return g:GetClassCount(Card.GetRace)==#g end
function ref.ssgfilter(g,tp,ft)
	if not (#g<=ft) then return false end
	local cg=Duel.GetMatchingGroup(ref.sscfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,nil,g)
	return cg:CheckSubGroup(ref.sscgfilter,#g,#g)
end
function ref.ssfilter(c,e,tp)
	return Marionightte.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c.has_text_race~=nil
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp):CheckSubGroup(ref.ssgfilter,1,2,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function ref.ssop(e,tp)
	local sg=Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Debug.Message(#sg)
	Debug.Message(sg:CheckSubGroup(ref.ssgfilter,1,2,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)))
	local g=sg:SelectSubGroup(tp,ref.ssgfilter,false,1,2,tp,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
		local cg=Duel.GetMatchingGroup(ref.sscfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,nil,g)
		cg:Sub(g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local scg=cg:SelectSubGroup(tp,ref.sscgfilter,false,#g,#g)
		Duel.SendtoGrave(scg,REASON_EFFECT)
	end
end

--Flicker
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function ref.desop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_REMOVE)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetTarget(ref.rettg)
		e1:SetOperation(ref.retop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_REMOVE+RESET_LEAVE))
		tc:RegisterEffect(e1)
		if (Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)<1) then e1:Reset() end
	end
end
function ref.rettg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
end
function ref.retop(e,tp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
