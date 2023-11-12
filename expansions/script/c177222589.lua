--Emerald Elegant Falcon
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,5,aux.FALSE,aux.FALSE)
	c:EnableReviveLimit()
	--Once per turn, you can also Time Leap Summon "Emerald Elegant Falcon" by using a Rank 4 Beast, Beast-Warrior or Winged Beast Xyz Monster. (This is treated as an additional Time Leap Summon.)
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
	--You can target 1 Beast, Beast-Warrior or Winged Beast monster in your GY and 1 card in your opponent's GY; shuffle both into the Deck, and if you do,
	--this card gains 700 ATK until the end of this turn, then if this card was Time Leap Summoned using an Xyz Monster, draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST+RACE_WINDBEAST+RACE_BEASTWARRIOR)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) and ((Duel.IsExistingMatchingCard(s.tlfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and s.checkatls(c,e,tp))
		or Duel.IsExistingMatchingCard(s.tlfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp))
end
function s.tlfilter1(c,e,tp)
	return c:IsFaceup() and c:IsLevel(4) and c:IsType(TYPE_EFFECT) and c:IsCanBeTimeleapMaterial() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
end
function s.tlfilter2(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and Duel.GetFlagEffect(tp,id)<=0 and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
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
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=Duel.SelectMatchingCard(tp,s.tlfilter2,tp,LOCATION_MZONE,0,0,1,nil,e,tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
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
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	if tlc==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else
		aux.TimeleapHOPT(tp) 
	end
end
function s.tdfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
	if e:GetHandler():GetMaterial():IsExists(Card.IsType,1,nil,TYPE_XYZ) and Duel.IsPlayerCanDraw(tp,1) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			if c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_XYZ) then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
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