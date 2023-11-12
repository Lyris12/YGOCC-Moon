--Time Leaping Sorceress
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,5,aux.FALSE,aux.FALSE)
	c:EnableReviveLimit()
	--You can only Special Summon "Time Leaping Sorceress(s)" once per turn.
	c:SetSPSummonOnce(id)
	--If your opponent Special Summoned a monster(s) this turn, this card's Time Leap Summon is treated as an Additional Time Leap Summon.
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
	--During your opponent's turn, If a monster(s) is Special Summoned to your opponent's field (except during the Damage Step): You can return this card you control to the Extra Deck,
	--and if you do, Special Summon 1 Future 6 Time Leap Monster from your Extra Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local opponent=1-tp
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,2,nil) and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and (s.checkatls(c,e,tp) or Duel.GetActivityCount(opponent,ACTIVITY_SPSUMMON)>0)
end
function s.tlfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local opponent=1-tp
	if Duel.GetActivityCount(opponent,ACTIVITY_SPSUMMON)<=0 then s.performatls(tp) end
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
	local opponent=1-tp
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	if Duel.GetActivityCount(opponent,ACTIVITY_SPSUMMON)<=0 then aux.TimeleapHOPT(tp) end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.GetTurnPlayer()~=tp
end
function s.spfilter(c,e,tp,ec)
	return c:IsFuture(6) and c:IsType(TYPE_TIMELEAP) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToExtra() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
		if sc then
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
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