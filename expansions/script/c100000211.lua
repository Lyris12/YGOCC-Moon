--[[
Eternadir Shift Field
Terreno Cangiante Eternadir
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:Activation()
	--You cannot Special Summon non-"Eternadir" monsters, except from the Extra Deck. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--During your Main Phase, you can conduct 1 Pendulum Summon of an "Eternadir" monster(s) in addition to your Pendulum Summon. (You can only gain this effect once per turn.)
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:HOPT()
	e2:SetValue(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_ETERNADIR))
	c:RegisterEffect(e2)
	--If you Pendulum Summon an "Eternadir" monster(s) (except during the Damage Step): You can add 1 "Eternadir" Pendulum Monster from your Deck to your Extra Deck face-up.
	local FChk=aux.AddThisCardInFZoneAlreadyCheck(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT()
	e3:SetLabelObject(FChk)
	e3:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e3)
end

--E1
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(ARCHE_ETERNADIR) and not c:IsLocation(LOCATION_EXTRA)
end

--E2
function s.pendvalue(e,c)
	return c:IsSetCard(ARCHE_ETERNADIR)
end

--E3
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsSetCard(ARCHE_ETERNADIR)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(ARCHE_ETERNADIR) and not c:IsForbidden()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
	local g=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end