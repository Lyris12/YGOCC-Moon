--[[
Automatyrant Asteroid Gears Dragon
Automatiranno Drago Asteroide di Ingranaggi
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	if not aux.EnableXyzLevelFreeMods then
		aux.EnableXyzLevelFreeMods=true
	end
	aux.AddXyzProcedureLevelFree(c,s.matfilter,nil,2,99)
	--[[For this card's Xyz Summon, you can also use Union Monster Cards you control in your Spell & Trap Zone as materials, and if you do, treat them as Level 8 Machine monsters.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ALLOW_EXTRA_XYZ_MATERIAL)
	e0:SetValue(s.extramat)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can destroy all cards your opponent controls.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.destg,
		s.desop
	)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can detach 1 material from this card, then target 1 monster in either GY; equip that target to this card as an Equip Spell
	that gives it 1000 ATK/DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.MainPhaseCond(),
		aux.DetachSelfCost(),
		s.eqtg,
		s.eqop
	)
	c:RegisterEffect(e2)
	--[[This card gains 800 ATK/DEF for each card equipped to it.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
end
s.has_text_type=TYPE_UNION

function s.matfilter(c,xyzc)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsXyzLevel(xyzc,8)
end
function s.extramat(e,c,xyzc,tp)
	return c:IsFaceup() and c:IsInBackrow() and c:IsControler(tp) and c:IsOriginalType(TYPE_UNION)
end

--E1
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E2
function s.eqfilter(c,tp)
	return c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(true,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	local g=Duel.Select(HINTMSG_EQUIP,true,tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
	Duel.SetCardOperationInfo(g,CATEGORY_LEAVE_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.EquipAndRegisterLimit(e,tp,tc,c,true) then
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

--E3
function s.atkval(e,c)
	return c:GetEquipCount()*800
end