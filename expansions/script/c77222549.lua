--Chronovert Aurum Dragon
local s,id=GetID()
function s.initial_effect(c)
	--You can only Special Summon "Chronovert Absolute Dragon(s)" once per turn.
	c:SetSPSummonOnce(id)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,9,aux.FALSE,aux.FALSE)
	c:EnableReviveLimit()
	--You can also Time Leap Summon this card by using "Chronovert Dragon" (this is treated as an additional Time Leap Summon).
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
	--Once per turn, when your opponent activates a card or effect (Quick Effect): You can return this card you control to the Extra Deck, and if you do, negate the activation, and if you do that,
	--shuffle it into the Deck, then you can Special Summon 1 "Chronovert Dragon" from your Extra Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.ngcon)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_DECK)
		ge1:SetLabel(id)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.GetFlagEffect(0,id)>2 and ((Duel.IsExistingMatchingCard(s.tlfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and s.checkatls(c,e,tp))
		or Duel.IsExistingMatchingCard(s.tlfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp))
end
function s.tlfilter1(c,e,tp)
	return c:IsFaceup() and c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
function s.tlfilter2(c,e,tp)
	return c:IsFaceup() and c:IsCode(177222522) and c:IsAbleToDeck()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local c=e:GetHandler()
	local g
	local tlc=false
	if (Duel.IsExistingMatchingCard(s.tlfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and s.checkatls(c,e,tp)) and Duel.IsExistingMatchingCard(s.tlfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) then
		tlc=Duel.SelectYesNo(tp,91)
	elseif not Duel.IsExistingMatchingCard(s.tlfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) then s.performatls(tp)
	else tlc=true end
	if tlc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g=Duel.SelectMatchingCard(tp,s.tlfilter2,tp,LOCATION_MZONE,0,0,1,nil,e,tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g=Duel.SelectMatchingCard(tp,s.tlfilter1,tp,LOCATION_MZONE,0,0,1,nil,e,tp)
	end
	if #g==0 then return false end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		e:SetLabel(tlc and 1 or 0)
		return true
	end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local tlc=e:GetLabel()
	if not g then return end
	c:SetMaterial(g)
	--The monster used for this card's Time Leap Summon is shuffled into the Deck instead of being banished.
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	if tlc==0 then aux.TimeleapHOPT(tp) end
end
function s.sfilter(c,e,tp)
	return c:IsCode(177222522) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	if re:GetHandler():IsAbleToDeck() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(tp) then
		if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,0,REASON_EFFECT)>0 then
			if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
				re:GetHandler():CancelToGrave()
				if Duel.SendtoDeck(re:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
					local sc=Duel.GetFirstMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
					if sc and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
						Duel.BreakEffect()
						Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
	end
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