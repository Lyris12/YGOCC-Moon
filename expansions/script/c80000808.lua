--Runecrafter Master

local m=80000808
local cm=_G["c"..m]

function cm.initial_effect(c)
	--fusion material
	Auxiliary.Add_Runeslots(c,1)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(cm.splimit)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.spcon)
	e2:SetOperation(cm.spop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.rpcon1)
	e3:SetValue(cm.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetCondition(cm.rpcon2)
	e4:SetValue(cm.defval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetDescription(aux.Stringid(m,0))
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCountLimit(1)
	e5:SetCondition(cm.rpcon3)
	e5:SetTarget(cm.retg1)
	e5:SetOperation(cm.reop1)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetDescription(aux.Stringid(m,1))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(cm.athtg)
	e6:SetOperation(cm.athop)
	c:RegisterEffect(e6)
end

function cm.rpcon1(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,red)
end

function cm.rpcon2(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,blue)
end

function cm.rpcon3(e,tp,eg,ep,ev,re,r,rp)
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,yellow)
end


function cm.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function cm.spfilter1(c,tp,fc)
	return c:IsCode(80000800) and c:IsCanBeFusionMaterial(fc)
end

function cm.spfilter2(c,tp,fc)
	return c:IsSetCard(0xfe9) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial(fc)
end


function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,cm.spfilter1,1,nil,tp,c) and Duel.CheckReleaseGroup(tp,cm.spfilter2,1,nil,tp,c)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectReleaseGroup(tp,cm.spfilter1,1,1,nil,tp,c)
	local g2=Duel.SelectReleaseGroup(tp,cm.spfilter2,1,1,g1:GetFirst(),c)
	g1:Merge(g2)
	c:SetMaterial(g1)
	Duel.Release(g1,REASON_COST+REASON_FUSION+REASON_MATERIAL)
end


function cm.atkfilter(c)
	return c:IsSetCard(0x0ff5) and c:GetAttack()>=0
end

function cm.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(cm.atkfilter,nil)
	return g:GetSum(Card.GetAttack) * 2
end

function cm.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(cm.atkfilter,nil)
	return g:GetSum(Card.GetAttack) * 2
end


function cm.retg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	local g=e:GetHandler():GetOverlayGroup():Filter(cm.atkfilter,nil)
	local rp = g:GetSum(Card.GetAttack) * 1/2
	Duel.SetTargetParam(rp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rp)
end

function cm.reop1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.GainRP(p,d)
end




function cm.athtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	g:KeepAlive()
	local xg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil)
	for xc in aux.Next(xg) do
		g:Merge(xc:GetOverlayGroup():Filter(cm.xyzfilter2,nil))
	end
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_OVERLAY)
end

function cm.athop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0
		or not Duel.IsExistingMatchingCard(cm.xyzfilter,tp,LOCATION_MZONE,0,1,nil) then 
			return 
	end
	local td=Duel.GetDecktopGroup(tp,0)
	local check=0
	Duel.Overlay(e:GetHandler(),td)
	for tc in aux.Next(td) do
		if e:GetHandler():GetOverlayGroup():IsContains(tc) then
			check=check+1
		end
	end
	if check>=0 then
		local g=Group.CreateGroup()
		g:KeepAlive()
		local xg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil)
		for xc in aux.Next(xg) do
			g:Merge(xc:GetOverlayGroup():Filter(cm.xyzfilter2,nil))
		end
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,1,1,nil)
			local atk = tg:GetFirst():GetAttack()
			Duel.GainRP(e:GetHandlerPlayer(),atk/2)
			Duel.SendtoGrave(tg,nil,REASON_EFFECT)
		end
		g:DeleteGroup()
	end
end

function cm.xyzfilter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0
end

function cm.xyzfilter2(c)
	return c:IsSetCard(0x0ff5)
end
