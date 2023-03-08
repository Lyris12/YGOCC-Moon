--created by Seth, coded by Lyris
--Mextro Gigarex
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetDescription(1123)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCondition(s.con)
	e1:SetTarget(s.rtg)
	e1:SetOperation(s.rop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetDescription(1108)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(s.cost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsSetCard(0xee5) and not c:IsType(TYPE_LINK)
end
function s.con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.rop()
	local d,p=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.dop(e,tp)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsSetCard(0xee5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,1152) then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else Duel.ShuffleHand(tp) end
	end
end
