--True Bigbang
local s,id=GetID()
function s.initial_effect(c)
	--If you control a Bigbang Monster: Choose 1 card your opponent controls in a Main Monster Zone or Spell & Trap Zone, and make your opponent destroy either it or all other cards they control in the same row (their choice).
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsType(TYPE_BIGBANG) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE+LOCATION_SZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,0)
end
function s.filter(c)
	return c:GetSequence()<5
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_SZONE)
	g=g:Filter(s.filter,nil)
	if #g<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tg=g:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	Duel.HintSelection(tg,true)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if not tc:IsInMainMZone(1-tp) then 
		g2=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
		g2=g2:Filter(s.filter,nil)
	end
	g2:RemoveCard(tc)
	local b1=aux.TRUE
	local b2=#g2>1
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off]=1
		off=off+1
	end
	local op=Duel.SelectOption(1-tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel then
		Duel.Destroy(sel==0 and tc or g2,REASON_RULE,LOCATION_GRAVE,1-tp)
	end
end
