--Zerost Machine Zerolt Mechanicus
--Macchina Zerost Zerolt Mechanicus
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,s.matfilter,2,6,true)
	--[[This Fusion Summoned card gains ATK/DEF equal to the number of materials used for its Fusion Summon x 600,
	also it gains ATK/DEF equal to half the ATK/DEF 1 Fusion Monster used as material for its Fusion Summon had on the field.]]
	local atk,def=c:UpdateATKDEF(s.statval(1),s.statval(2),nil,nil,nil,aux.FusionSummonedCond)
	local e1x=Effect.CreateEffect(c)
	e1x:Desc(0)
	e1x:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1x:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CANNOT_DISABLE)
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1x:SetCondition(aux.FusionSummonedCond)
	e1x:SetOperation(s.atkop)
	c:RegisterEffect(e1x)
	atk:SetLabelObject(e1x)
	def:SetLabelObject(e1x)
	local e1y=Effect.CreateEffect(c)
	e1y:SetType(EFFECT_TYPE_SINGLE)
	e1y:SetCode(EFFECT_MATERIAL_CHECK)
	e1y:SetLabelObject(e1x)
	e1y:SetValue(s.valcheck)
	c:RegisterEffect(e1y)
	--[[If this card is Fusion Summoned: Roll a six-sided die, then, as long as this card remains face-up on the field,
	you can use the following effect of "Zerost Machine Zerolt Mechanicus" a number of times per turn up to the result.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(aux.FusionSummonedCond)
	e2:SetTarget(s.dicetg)
	e2:SetOperation(s.diceop)
	c:RegisterEffect(e2)
	--[[When your opponent activates a card or effect (Quick Effect): Make both players roll a six-sided die, and if your result is higher than your opponent's, negate the activation.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_DICE|CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.toss_dice = true

function s.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(ARCHE_ZEROST) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionType,1,nil,TYPE_FUSION))
end

function s.statval(pos)
	return	function(e,c)
				local ct=e:GetHandler():GetMaterialCount()
				if not ct or ct<0 then ct=0 end
				local val = e:GetLabelObject():GetSpecificLabel(pos) or 0
				return ct*600 + val
			end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local mg=g:Filter(Card.IsFusionType,nil,TYPE_FUSION)
	mg:KeepAlive()
	e:GetLabelObject():SetLabelObject(mg)
end
function s.atkop(e,tp)
	e:SetLabel(0,0)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if c:IsFaceup() then
		if g then
			if #g>0 then
				local tc=g:Select(tp,1,1,nil):GetFirst()
				Duel.Hint(HINT_CARD,tp,id)
				if tc:IsPublic() then
					Duel.HintSelection(Group.FromCards(tc))
				else
					Duel.ConfirmCards(1-tp,Group.FromCards(tc))
				end
				local atk, def = math.ceil(tc:GetAttack()/2), math.ceil(tc:GetDefense()/2)
				if not atk then atk=0 end
				if not def then def=0 end
				e:SetLabel(atk,def)
			end
			g:DeleteGroup()
		end
	else
		if g then
			g:DeleteGroup()
		end
	end
end

function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	if c:IsRelateToChain() and c:IsFaceup() then
		Duel.BreakEffect()
		c:SetHint(CHINT_NUMBER,dc)
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT,1,dc,aux.Stringid(id,2))
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetFlagEffect(tp,id)
		if not ct then ct=0 end
		return Duel.IsExistingMatchingCard(Card.HasFlagEffectLabelHigher,tp,LOCATION_MZONE,0,1,nil,id,ct)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local dc1,dc2=Duel.TossDice(tp,1,1)
	if dc1>dc2 and Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToChain(ev) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end