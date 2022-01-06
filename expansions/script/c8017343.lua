--Pandempandora
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetSPSummonOnce(id)
	--link summon
	aux.AddLinkProcedure(c,cid.mfilter,2,2)
	c:EnableReviveLimit()
	--extra pande summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.sumcon)
	e1:SetOperation(cid.sumsuc)
	c:RegisterEffect(e1)
	--destroy ED
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.drycon)
	e2:SetTarget(cid.drytg)
	e2:SetOperation(cid.dryop)
	c:RegisterEffect(e2)
	--nuke
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.nukecon)
	e3:SetTarget(cid.nuketg)
	e3:SetOperation(cid.nukeop)
	c:RegisterEffect(e3)
end
--GENERIC FILTERS
function cid.mfilter(c)
	return c:IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
--EXTRA PANDE SUMMON
function cid.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PANDEMONIUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(function (e,c) return true end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--DESTROY ED
function cid.cfilter(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(tp) 
		and ((c:IsPreviousLocation(LOCATION_MZONE) and bit.band(c:GetPreviousTypeOnField(),TYPE_PANDEMONIUM+TYPE_MONSTER)~=0)
			or (c:IsPreviousLocation(LOCATION_SZONE) and (bit.band(c:GetPreviousTypeOnField(),TYPE_PANDEMONIUM)~=0 or c:GetFlagEffect(716)>0)))
end
function cid.dryfilter(c,e)
	return c:IsDestructable(e)
end
------------
function cid.drycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.drytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_EXTRA,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_EXTRA)
end
function cid.dryop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_EXTRA,0,1,1,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--NUKE
function cid.pandfilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
--------------
function cid.nukecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.pandfilter,5,nil,tp)
end
function cid.nuketg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.nukeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end