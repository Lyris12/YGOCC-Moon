--Gaia Knight From a Different Time
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	--aux.AddTimeleapProc(c,8,s.sumcon,s.tlfilter)
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
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetFlagEffect(tp,EFFECT_EXTRA_TIMELEAP_MATERIAL)<=0
end
function s.tlfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and (c:IsLevel(7) or (c:IsLevelBelow(6) and c:IsAttackAbove(1400))) and not c:IsType(TYPE_TOKEN)
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP) and c:IsCanBeTimeleapMaterial() --and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tlfilter,tp,LOCATION_MZONE,0,0,1,true,nil,tp)
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
