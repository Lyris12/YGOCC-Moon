--Ennesima Markshall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_DESTROY)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCountLimit(1,id)
	p1:SetCondition(aux.PandActCheck)
	p1:SetCost(cid.actcost)
	p1:SetTarget(cid.acttg)
	p1:SetOperation(cid.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,nil,TYPE_EFFECT+TYPE_TUNER)
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(cid.sumfilter)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.spcon)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end
--ACTIVATE
function cid.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
		and c:IsAbleToDeckAsCost()
end
function cid.setfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function cid.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,3,3,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
end
function cid.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(cid.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(cid.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(cid.setfilter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		aux.PandSSet(g,REASON_EFFECT,aux.GetOriginalPandemoniumType(g:GetFirst()))(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,g)
		if g:GetFirst():IsLocation(LOCATION_SZONE) and g:GetFirst():IsFacedown() and g:GetFirst():IsSetCard(0x7a4) then
			local cg=g:GetFirst():GetColumnGroup():Filter(aux.TRUE,g:GetFirst())
			if #cg==0 then return end
			Duel.Destroy(cg,REASON_EFFECT)
		end
	end
end

--EXTRA SUMMON
function cid.sumfilter(e,c)
	return c:IsSetCard(0x7a4) and c:IsLevel(4)
end

--SPSUMMON
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re and (re:GetHandler():IsSetCard(0x7a4) or re:IsActiveType(TYPE_SPELL+TYPE_TRAP))
end
function cid.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or (c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end