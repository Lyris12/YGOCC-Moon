--Winter Spirit Snowman
--  Idea: Alastar Rainford
--  Script: Shad3
--  Editor: Keddy, Glitchy

local s,id=GetID()
function s.initial_effect(c)
	--FLIP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER|CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.a_tg)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	local e1y=e1:Clone()
	e1y:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1y)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
	--putcounter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.d_cd)
	e4:SetOperation(s.d_op)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.c_cd)
	e5:SetTarget(s.c_tg)
	e5:SetOperation(s.c_op)
	c:RegisterEffect(e5)
	--Deck Redirect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetOperation(s.hintop)
	c:RegisterEffect(e6)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e8:SetValue(LOCATION_DECKSHF)
	e8:SetCondition(s.e_cd)
	c:RegisterEffect(e8)
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_POSITION)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,COUNTER_ICE,1)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc:AddCounter(COUNTER_ICE,1) then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsPosition(POS_ATTACK) then 
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		end
	end
end

function s.d_cd(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsRelateToBattle()
end
function s.d_op(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsCanAddCounter(COUNTER_ICE,1) then
		Duel.Hint(HINT_CARD,tp,id)
		bc:AddCounter(COUNTER_ICE,1)
	end
end

function s.c_cd(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end

function s.c_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end

function s.c_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateAttack() and c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.hintop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&(~RESET_TURN_SET)),EFFECT_FLAG_CLIENT_HINT,1,0,STRING_SPECIAL_SUMMONED)
end
function s.e_cd(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end