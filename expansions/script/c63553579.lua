--Markshall Mark
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--place or set
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.pctg)
	e2:SetOperation(cid.pcop)
	c:RegisterEffect(e2)
end
--ACTIVATE
function cid.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7a4) and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(cid.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function cid.tgfilter(c,attr)
	return c:IsSetCard(0x7a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsAttribute(attr)
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x7a4) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if not tc:IsFaceup() then return end
		local attr=tc:GetAttribute()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.tgfilter,tp,LOCATION_DECK,0,1,1,nil,attr)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
			if sc then
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--PLACE OR SET
function cid.filter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalAttribute(),e,tp,eg,ep,ev,re,r,rp)
end
function cid.pfilter(c,attr,e,tp,eg,ep,ev,re,r,rp)
	return c:IsSetCard(0x7a4) and c:GetOriginalAttribute()~=attr and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and (c:IsType(TYPE_PENDULUM) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or (c:IsType(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(c)(nil,e,tp,eg,ep,ev,re,r,rp)))
end
function cid.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.filter(chkc,e,tp,eg,ep,ev,re,r,rp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_SZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
end
function cid.pcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local attr=tc:GetOriginalAttribute()
		local g=Duel.GetMatchingGroup(cid.pfilter,tp,LOCATION_DECK,0,nil,attr,e,tp,eg,ep,ev,re,r,rp)
		if #g<=0 then return end
		local b1=g:FilterCount(Card.IsType,nil,TYPE_PENDULUM)>0
		local b2=g:FilterCount(Card.IsType,nil,TYPE_PANDEMONIUM)>0
		local b={b1,b2}
		if not b[1] and not b[2] then return end
		local off=1
		local ops={}
		local opval={}
		for i=1,2 do
			if b[i] then
				ops[off]=aux.Stringid(id,i+2)
				opval[off]=i-1
				off=off+1
			end
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local sg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_PENDULUM)
			Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local sg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_PANDEMONIUM)
			aux.PandSSet(sg:GetFirst(),REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end