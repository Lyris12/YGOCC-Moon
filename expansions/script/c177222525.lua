--Gaia Knight From a Different Time
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,8,aux.FALSE,aux.FALSE)
	c:EnableReviveLimit()
	--You can also Time Leap Summon this card using a Level 6 or lower non-Token monster with 1400 or more ATK.
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
end
function s.cfilter(c)
	return c:IsDefensePos()
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and s.checkatls(c,e,tp)
end
function s.tlfilter(c,e,tp)
	return c:IsFaceup() and (c:IsLevel(7) or (c:IsLevelBelow(6) and c:IsAttackAbove(1400))) and not c:IsType(TYPE_TOKEN)
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial() --and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
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
	c:SetMaterial(g)
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
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