--Pastel Palettes - Band Aya
--Script by XyLeN
function c20015004.initial_effect(c)
	--enable return
	aux.EnablePastelPalettesReturn(c,aux.Stringid(20015004,1),aux.Stringid(20015004,2),20015004,20015004)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20015004,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,20015004+200)
	e1:SetTarget(c20015004.atktg)
	e1:SetOperation(c20015004.atkop)
	c:RegisterEffect(e1)
end
function c20015004.atkfilter(c)
	return c:IsFaceup() and aux.LvL6or7Check(c)
end
function c20015004.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20015004.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c20015004.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c20015004.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end

dofile("script/Pastel Palettes Core.lua")