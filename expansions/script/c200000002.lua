--Naval Gears - Z25
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
		--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.hspcon)
	e1:SetOperation(cid.hspop)
	c:RegisterEffect(e1)
	--If grave by not battle or effects; shuffle card to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83239739,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.condition)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
--If grave by not battle or effects; shuffle card to deck
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return not (bit.band(r,REASON_BATTLE+REASON_DESTROY)==REASON_BATTLE+REASON_DESTROY) 
		and not ((bit.band(r,REASON_EFFECT)==REASON_EFFECT) and rp==tp)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)  end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) and 
			Duel.SelectYesNo(tp,aux.Stringid(4777,0))
			then
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			local tc=g:GetFirst()
				if g:GetCount()>0 then
				Duel.HintSelection(g)
				Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
			end
		end
	end
end
--special summon
function cid.spfilter(c)
	return c:IsSetCard(0x700) and c:IsAbleToGraveAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function cid.hspcon(e,c)
	if c==nil then return true end
		return Duel.IsExistingMatchingCard(cid.spfilter,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,0,1,e:GetHandler())
end
function cid.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=0 then
		local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,e:GetHandler())
		Duel.SendtoGrave(g,POS_FACEUP,REASON_COST)
	else
		local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
		Duel.SendtoGrave(g,POS_FACEUP,REASON_COST)
	end
end