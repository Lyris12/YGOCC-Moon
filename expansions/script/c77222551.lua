--Chronoverting Chronoverter
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,2,aux.FALSE,aux.FALSE)
	c:EnableReviveLimit()
	--You can also Time Leap Summon this card by using a "Chronovert" monster, except "Chronoverting Chronoverter".
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--If this card is Time Leap Summoned: You can make your opponent choose and apply 1 of these effects ('you' in these effects means that opponent). 
	--● Shuffle 1 card from your hand or field into the Deck. 
	--● Your opponent draws 2 cards, then shuffles 1 card from their hand or field into the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.applycon)
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0 and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and s.checkatls(c,e,tp)
end
function s.tlfilter(c,e,tp)
	return (c:IsType(TYPE_EFFECT) and c:IsLevel(1) and c:IsFaceup()) or (c:IsFaceup() and c:IsSetCard(0x724) and not c:IsCode(id))
		and c:IsAbleToDeck() --and c:IsCanBeTimeleapMaterial() and (Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	s.performatls(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tlfilter,tp,LOCATION_MZONE,0,0,1,nil,e,tp)
	if #g==0 then return false end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	e:GetHandler():SetMaterial(g)
	--The monster used for this card's Time Leap Summon is shuffled into the Deck instead of being banished.
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
function s.applycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsPlayerCanDraw(tp,2)
	if chk==0 then return b1 or b2 end
	if b1 then Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE+LOCATION_HAND) end
	if b2 then 
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
	end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsPlayerCanDraw(tp,2)
	if not (b1 or b2) then return end
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
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		local tc=g:GetFirst()
		if #g>0 then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
	elseif sel==1 then
		Duel.Draw(tp,2,REASON_EFFECT)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		local tc=g:GetFirst()
		if #g>0 then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
	end
end
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_MONSTER)
end


--STUFF TO MAKE IT WORK WITH EFFECT_EXTRA_TIMELEAP_SUMMON
function s.checkatls(c,e,tp)
	if c==nil then return true end
	if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
	local exsumcheck=false
	for _,te in ipairs(eset) do
		if not te:GetValue() or type(te:GetValue())=="number" or te:GetValue()(e,c) then
			exsumcheck=true
		end
	end
	eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_IGNORE_TIMELEAP_HOPT)}
	local ignsumcheck=false
	for _,te in ipairs(eset) do
		if te:CheckCountLimit(tp) then
			ignsumcheck=true
			break
		end
	end
	return (Duel.GetFlagEffect(tp,828)<=0 or (exsumcheck and Duel.GetFlagEffect(tp,830)<=0) or c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_HOPT) or ignsumcheck)
end
function s.performatls(tp)
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
	local igneset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_IGNORE_TIMELEAP_HOPT)}
	local exsumeff,ignsumeff
	local options={}
	if (#eset>0 and Duel.GetFlagEffect(tp,830)<=0) or #igneset>0 then
		local cond=1
		if Duel.GetFlagEffect(tp,828)<=0 then
			table.insert(options,aux.Stringid(433005,15))
			cond=0
		end
					
		for _,te in ipairs(eset) do
			table.insert(options,te:GetDescription())
		end
		for _,te in ipairs(igneset) do
			if te:CheckCountLimit(tp) then
				table.insert(options,te:GetDescription())
			end
		end
					
		local op=Duel.SelectOption(tp,table.unpack(options))+cond
		if op>0 then
			if op<=#eset then
				exsumeff=eset[op]
			else
				ignsumeff=igneset[op-#eset]
			end
		end
	end
	
	if exsumeff~=nil then
		Duel.RegisterFlagEffect(tp,829,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,exsumeff:GetHandler():GetOriginalCode())
	elseif ignsumeff~=nil then
		Duel.Hint(HINT_CARD,0,ignsumeff:GetHandler():GetOriginalCode())
		ignsumeff:UseCountLimit(tp)
	end
end