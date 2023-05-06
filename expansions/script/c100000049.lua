--Dreamy Forest, Dreary Forest
--Foresta Sognante, Foresta Tetra
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Activate()
	--[["Dreamy Forest" monsters you control gain 500 ATK, and cannot be destroyed by card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DREAMY_FOREST))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	--[["Dreary Forest" monsters you control gain 500 DEF, and cannot be targeted by your opponent's card effects.]]
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DREARY_FOREST))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2x:SetValue(aux.tgoval)
	c:RegisterEffect(e2x)
	--[[If a "Dreamy Forest" monster(s) you control Transforms (except during the Damage Step): You can discard 1 random card from your opponent's hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TRANSFORMED)
	e3:SetRange(LOCATION_SZONE)
	e3:SHOPT()
	e3:SetCondition(aux.PreTransformationCheckSuccess)
	e3:SetTarget(s.dctg)
	e3:SetOperation(s.dcop)
	c:RegisterEffect(e3)
	--[[If a "Dreary Forest" monster(s) you control Transforms (except during the Damage Step): You can draw 1 card.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_TRANSFORMED)
	e4:SetRange(LOCATION_SZONE)
	e4:SHOPT()
	e4:SetCondition(aux.PreTransformationCheckSuccess)
	e4:SetTarget(s.drawtg)
	e4:SetOperation(s.drawop)
	c:RegisterEffect(e4)
	aux.AddPreTransformationCheck(c,e3,s.tfcon(ARCHE_DREAMY_FOREST))
	aux.AddPreTransformationCheck(c,e4,s.tfcon(ARCHE_DREARY_FOREST))
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

function s.tffilter(c,tp,arche)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(arche)
end
function s.tfcon(arche)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return eg:IsExists(s.tffilter,1,nil,tp,arche)
			end
end