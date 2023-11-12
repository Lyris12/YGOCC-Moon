--[[
Keeper of Harmony
Custode dell'Armonia
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.HasVibe,2,2,s.matcon)
	c:EnableReviveLimit()
	--[[During the Main Phase, if this card was Special Summoned by destroying a monster that was Special Summoned from the Extra Deck as material:
	You can target 1 monster in your GY with a different Vibe from every face-up monster you control; Special Summon it, but it cannot activate its effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	--[[If you Synchro Summoned using this card as material, and the other materials all had different Vibes from each other and from this card:
	You can target 1 face-up Synchro Monster on the field; it is unaffected by card effects, except its own.]]
	local e5=Effect.CreateEffect(c)
	e5:Desc(1)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:HOPT()
	e5:SetLabel(0)
	e5:SetFunctions(s.uncon,nil,s.untg,s.unop)
	c:RegisterEffect(e5)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabelObject(e5)
	e3:SetValue(s.matcheck2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(0xff)
	e4:SetTargetRange(0xff,0xff)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.matcon(g,lc)
	return g:GetClassCount(Card.GetVibe)==#g
end

--E1
function s.spfilter(c,e,tp)
	return c:HasVibe() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExists(false,s.vbfilter,tp,LOCATION_MZONE,0,1,nil,c:GetVibe())
end
function s.vbfilter(c,vibe)
	return c:IsFaceup() and c:GetVibe()==vibe
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and e:GetHandler():HasFlagEffect(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(STRING_CANNOT_TRIGGER)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

--E2
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsSpecialSummoned,1,nil,LOCATION_EXTRA) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

--E3
function s.matcheck2(e,c)
	local obj=e:GetLabelObject()
	local ec=obj:GetOwner()
	local g=c:GetMaterial()
	if g:IsContains(ec) and not g:IsExists(aux.NOT(Card.HasVibe),1,nil) and g:GetClassCount(Card.GetVibe)==#g then
		obj:SetLabel(1)
	else
		obj:SetLabel(0)
	end
end
--E4
function s.eftg(e,c)
	return c:IsMonster(TYPE_SYNCHRO)
end
--E5
function s.uncon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_SYNCHRO~=0 and e:GetLabel()==1
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.untg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.unop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(STRING_UNAFFECTED_BY_OTHER_EFFECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end